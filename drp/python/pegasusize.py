#!/usr/bin/env python

import argparse
import os
import re
import Pegasus.DAX3 as peg

def generateDax(f, name="dax", noInitJob=False, initPickle=None):
    """Generate a Pegasus DAX abstract workflow"""
    dax = peg.ADAG(name)

    # All jobs depend on the butler yaml
    butler = peg.File("butler.yaml")
    dax.addFile(butler)

    if not noInitJob:
        # Add the init job
        init = peg.Job(name="pipetask", id=999999) # need a unique number
        pickle = peg.File(initPickle)
        dax.addFile(pickle)
        init.uses(pickle, link=peg.Link.INPUT)
        init.uses(butler, link=peg.Link.INPUT)
        init.addArguments("run", "-b", butler, "-i INCOL --output-run OUTCOL",
                          "--init-only --register-dataset-types --qgraph", pickle)
        logfile = peg.File("log.init.out")
        dax.addFile(logfile)
        init.setStderr(logfile)
        init.uses(logfile, link=peg.Link.OUTPUT)
        dax.addJob(init)

    for line in f:
        # To add a job
        if line.startswith("Quantum"):
            match = re.search(r"(\d+): (\w+)", line)
            iq = int(match.group(1))
            taskname = match.group(2)
            print("Adding job", iq, taskname, " #", line.rstrip('\n'))
            # Pegasus Job cannot have id=0, hack it...FIXME
            # Assuming there are <99999 jobs in total
            job = peg.Job(name="pipetask", id=iq+100000)

            demandingTasks = set(['MakeWarpTask', 'CompareWarpAssembleCoaddTask',
                                  'DeblendCoaddSourcesSingleTask',
                                  'MeasureMergedCoaddSourcesTask'])
            job.addProfile(peg.Profile(peg.Namespace.CONDOR, "request_cpus", "1"))
            if taskname in demandingTasks:
                job.addProfile(peg.Profile(peg.Namespace.CONDOR, "request_memory", "28GB"))
            else:
                job.addProfile(peg.Profile(peg.Namespace.CONDOR, "request_memory", "2GB"))

            filename = "quantum-%06d.pickle" % iq
            pickle = peg.File(filename)
            dax.addFile(pickle)
            job.uses(pickle, link=peg.Link.INPUT)
            job.uses(butler, link=peg.Link.INPUT)
            job.addArguments("run", "-b", butler, "-i INCOL --output-run OUTCOL",
                             "--extend-run --skip-init-writes",
                             "--clobber-partial-outputs --skip-existing --qgraph", pickle)

            logfile = peg.File("log.%s.%06d.out" % (taskname, iq) )
            dax.addFile(logfile)
            job.setStderr(logfile)
            job.uses(logfile, link=peg.Link.OUTPUT)
   
            dax.addJob(job)
            if not noInitJob:
                # Every job depends on the init job
                dax.depends(parent=init, child=job)

        # To add a job dependency
        if line.startswith("Parent Quantum"):
            match = re.search(r"Parent Quantum (\d+) - Child Quantum (\d+)", line)
            # FIXME
            parent = int(match.group(1))+100000
            child = int(match.group(2))+100000
            dax.depends(parent=parent, child=child)
            print("Adding dependency", parent, child)

    return dax


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate a DAX")
    parser.add_argument("-i", "--inputData", default="wf",
                        help="a file including information")
    parser.add_argument("-o", "--outputFile", type=str, default="wf.dax",
                        help="file name for the output dax xml")
    parser.add_argument("--noInit",  action='store_true',
                        help="a flag to ignore the init job")
    parser.add_argument("--initPickle", type=str, default="test.pickle",
                        help="file name of the wf pickle that will be used in the init job ")

    args = parser.parse_args()

    with open(args.inputData, "r") as f:
        dax = generateDax(f, "ciHsc", args.noInit, args.initPickle)
    with open(args.outputFile, "w") as f:
        dax.writeXML(f)
