#!/usr/bin/env python

"""
Automate runs of GAMS based advanced power models

NOT COMPLETE. STILL MIGRATING FROM RELATED TOOLS

"""
__author__ = "Bryan Palmintier (b_p [at] mit [dot] edu)"
__copyright__ = "Copyright (c) 2011 Bryan Palmintier"
__license__ = "GPLv3.0"

## ===== History ====
# ver     date     time      who      Comments
# ---  ----------  -----  ----------  --------------------------------------- 
__version__, __date__ = "1", "2011-08-07"
#   1  2011-08-07  20:45    BryanP    Original Code

from optparse import OptionParser
import sys

## module variables (wishlist convert to my variables in future python)
options = []        #commandline options

#Default extents for region to include
extents = {'s':-39, 'n':-38, 'w':10, 'e':90}


#---- MAIN ----
def main():
    """ You guessed it, sucks in the file and processes it
    """

    #Deal with all of the command line options. Unused arguements in args
    args = HandleOptions()

    #== Suck in Data from files ==
    for col in range(ncols):
        for row in range(nrows):
            lat = yllcorner + cellsize/2 + row * cellsize
            lon = xllcorner + cellsize/2 + col * cellsize

            #try to open the corresponding file
            try:
                filename="%s_%s_%s" % (in_file_root, lat, lon)
                f = open(filename, 'r')
            except:
                #if there is an error, skip this file
                print 'unable to open %s' % filename
                continue
            
            #loop over all of the lines in the file
            for line in f:
                #separate each row into columns, by default, any string of
                #white space (tabs, spaces, etc) is used as the separtor,
                #which is good b/c the VIC outputs mix tabs and spaces
                data_col=line.split()

                # Now we build up the data string to sort by
                date_string = '-'.join(data_col[group_by])

                #if this is a new data group, intialize our results and count dictionaries
                if not results.has_key(date_string):
                    results[date_string] = deepcopy(empty_grid)
                    count[date_string] = deepcopy(empty_count)

                #only average in valid data by skipping the value update for no-data fields
                if data_col[to_avg-1] == NODATA_value:
                    continue
                
                count[date_string][row][col] += 1
                # if this is the first valid data
                if results[date_string][row][col] == NODATA_value:
                    # just use the value
                    results[date_string][row][col] = float(data_col[to_avg-1])
                else:
                    # otherwise average it in
                    results[date_string][row][col] *= (count[date_string][row][col]-1)/count[date_string][row][col]
                    results[date_string][row][col] += 1/count[date_string][row][col] * float(data_col[to_avg-1])

    #== Print Results to File(s) ==
    for date_string in results.keys():
        filename = "%s_%s" % (out_file_root, date_string)
        out_file = open(filename, 'w')
        print 'writing %s' % filename

        #write header
        out_file.write('ncols         %d\n'% ncols)
        out_file.write('nrows         %d\n'% nrows)
        out_file.write('xllcorner     %.4f\n'% xllcorner)
        out_file.write('yllcorner     %.4f\n'% yllcorner)
        out_file.write('cellsize      %.4f\n'% cellsize)
        out_file.write('NODATA_value  %d\n'% NODATA_value)
     
        #write rows in reverse order b/c we started with the lower left
        #corner when reading, but want to start with the upper left corner
        #for the grid
        for row in range(nrows-1, -1, -1):
            for col in range(ncols):
                if results[date_string][row][col] == NODATA_value:
                    out_file.write('%d '% NODATA_value)
                else:
                    #%.4f specifies 4 digits after the decimal place for a floating point
                    out_file.write('%.4f '% results[date_string][row][col])
            out_file.write('\n')
        out_file.close()
    
# Helper function to handle command line options
def HandleOptions():
    """ Handles command line options and associated help strings
    """
    global options, extents

    #help strings
    usage = "NOT WORKING YET usage: %prog [-hvq] [-w work_dir] [-m model] [-g gams_opt] [-t #] [-i #] state_list_files"
    version="%prog" + " ver. %s" % __version__
    description = """
Utility for selecting a geographic region within a VIC global soil parameter file
NOT COMPLETE. STILL MIGRATING FROM RELATED TOOLS
""" 
    help_verbose = "Display processing status (default=%default)"
    help_quiet = "Suppress status display (Opposite of verbose)"
    help_outfile = """Write results to OUTFILE (default = input filename + ".out") this option only works for a single input file """
    help_dir = "Extent in associated direction (lat/long), use quotes for negatives"

    #add options to parser
    parser = OptionParser(usage=usage, version=version, description=description)
    parser.add_option("-v", "--verbose",
                      action="store_true", dest="verbose",
                      default = True,
                      help=help_verbose)
    parser.add_option("-q", "--quiet",
                      action="store_false", dest="verbose",
                      help=help_quiet)
    parser.add_option("-o", "--outfile", help=help_outfile)
    parser.add_option("-w", "--work_dir" ,
                      default = "../work", help=help_work_dir)
    parser.add_option("-m", "--model" ,
                      default = "../dispatch/OpsLp.gms", help=help_model)
    parser.add_option("-g", "--gams_opt" ,
                      default = " -errmsg=1", help=help_gams_opt)
    parser.add_option("-t", "--threads" ,
                      default = 1, help=help_threads)
    parser.add_option("-i", "--thread_id" ,
                      default = 1, help=help_thread_id)
    

    #actually parse the command line
    (options, args) = parser.parse_args()
    
    extents['n'] = float(options.n)
    extents['e'] = float(options.e)
    extents['s'] = float(options.s)
    extents['w'] = float(options.w)

    if not options.prompt and len(args) == 0:
        parser.print_usage()
        exit(0)
        
    #return filenames from command line
    return args

def CreateFileList(raw_list):
    
    files = []

    #create list from command line arguements, if any, expanding wildcards along the way
    for item in raw_list:
        files.extend(glob.glob(item))
        
    if options.prompt:
        #Note: by creating a root Tk object, we are able to close the blank Tk window when we are done.
        tk_root = Tkinter.Tk()
        filetypes = [("All Files", "*.*")]
        files=list(tkFileDialog.askopenfilenames
                     (parent = tk_root, filetypes=filetypes,
                      title = 'Select VIC Soil Parameter File(s) to process...'))
        tk_root.destroy()
        
    return files


if __name__ == "__main__":
    main()
    
