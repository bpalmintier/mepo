#! /usr/local/bin/python

"""
ldc Produces load duration curves and related plots for AdvPwr models

Classes:
  NONE

Implemented Methods:
  main()              #the main LDC program

Notes:

"""
__author__ = "Bryan Palmintier"
__copyright__ = "Copyright (c) 2012 Bryan Palmintier"
__license__ = """GPLv3 --
   This file is part of the Advanced Power Tool Suite (AdvPwr).

    AdvPwr is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    AdvPwr is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with AdvPwr.  If not, see <http://www.gnu.org/licenses/>.
"""

## ===== History ====
#  [Current]            version     date       time     who     Comments
#                       -------  ----------    ----- ---------- ------------- 
__version__, __date__ = "0.6a", "2012-10-07"  #13:47   BryanP   Add ability to hide legend

# [Older, in reverse order]
# version      date       time     who     Comments
# -------   ----------    ----- ---------- --------------------------------------- 
#  "0.5a", "2012-10   "  #15:22   BryanP   Tweaks and cleanup
#  "0.4a", "2012-09-05"  #15:22   BryanP   Re-sort for merit order, many more options to hone figure#   0.3a  2012-09-03 22:22   BryanP   Expanded command line options: first, duration, title, legend
#   0.2a    2012-09-02    11:12   BryanP   Updated gen list for thesis
#   0.1a    2012-02-22    23:00   BryanP   Initial Code
 
# Import the core scientific libraries
import numpy as np
import scipy as sp
import matplotlib
#import matplotlib.pylab as plt in handleCommandLine() to allow on the fly backend changes

# Other libraries
import argparse     # Improved standard library that replaces optparse for Python 2.7+
import csv          # Simple csv parsing, used for headers. np methods better for large data
import os.path      # file extraction, etc.
     
import pdb          # Python debugger use pdb.set_trace() to set a breakpoint
     
def main():

    args = handleCommandLine();
    
    for f in args.pwr_files:
        plotLDC(f, args)
        
    #Pause so window stay open
    # Note: on python 3k replace with input()
    raw_input('Press Enter to Close\n')

#-------------------
# plotLDC
#-------------------
def plotLDC(pwr_file, args):
    
    #Read and parse first line from power table using the csv tools
    # This defines the generator names and also identifies the number of columns to expect
    pwr_as_csv = csv.reader(pwr_file, skipinitialspace=True)
    gens = pwr_as_csv.next() #parses the header line
    gens.pop(0) #remove the blank time column header
    
    #Now suck in the rest of the data directly into an ndarray
    # Note: surprisingly genfromtxt seems to run faster than loadtxt
    # Note: we have already handled the header row, so now we use the skip_header option to 
    #  plot partial years
    pwr = np.genfromtxt(pwr_file, delimiter=',', usecols=range(1,len(gens)+1), skip_header=args.first)
    
    # Trim power to desired duration
    pwr = pwr[0:args.dur,:]
    
    #Compute the total demand for each hour
    demand = np.sum(pwr, axis=1)

    #Sort along the time axis 
    if args.sort != 'time': #Nothing to do if just want to plot in time order
        if args.sort == 'load':
            sort = demand.argsort()     #List of sorted indicies
        elif args.sort == 'net':
            net_demand = demand.copy();
            if 'wind' in gens:
                net_demand -= pwr[:,gens.index('wind')]
            sort = net_demand.argsort()     #List of sorted indicies
        #reverse order so we have a descending display
        sort = sort[::-1]
        
        pwr = pwr[sort,:]
        
    else:
        sort = np.arange(len(pwr))

    #Handle reserve data
    if args.rsrv_spin is None:
        data = pwr
    else:
        #Extract wind data for reserve calcs
        if 'wind' in gens:
            wind_pwr = pwr[:,gens.index('wind')]
            if args.wind_cap_GW is None:
                args.wind_cap_GW = np.nanmax(wind_pwr)
        else:
            wind_pwr = np.zeros(size(pwr,0),1)
            if args.wind_cap_GW is None:
                args.wind_cap_GW = 0
    
        #Read and parse reserve data in the same way as power data
        rsrv = np.genfromtxt(args.rsrv_spin, delimiter=',', usecols=range(1,len(gens)+1), skip_header=args.first)
        
        # Trim reserves to desired duration
        rsrv = rsrv[0:args.dur,:]
        data = rsrv
        
        # And compute required Reserve time series
        rsrv_outage =  args.SpinReserveMinGW * np.ones_like(demand)
        rsrv_for_load = demand * args.SpinReserveLoadFract
        rsrv_for_wind = wind_pwr * args.WindFlexUpForecast + args.wind_cap_GW * args.WindFlexUpCapacity
        rsrv_load_and_outage = rsrv_for_load + rsrv_outage
        rsrv_tot = rsrv_for_load + rsrv_outage + rsrv_for_wind

    #Sort generator order
    # FIXME: Make more general
    if args.gen_set == 'ClustUC':
        gen_order = [
                        'u235_st',
                        'coal_lig_st',
                        'coal_sub_st',
                        'ng_cc',
                        'ng_gt',
                        'ng_st',
                        'wind'
                    ]
    else:
        #For Expansion Planning Problems
        gen_order = [
                        'old_nuke_st',
                        'new_nuke_st',
                        'new_coal_st_ccs',
                        'new_coal_st',
                        'old_coal_lig_st',
                        'old_coal_sub_st',
                        'new_ng_cc_ccs',
                        'new_ng_cc',
                        'old_ng_cc',
                        'old_ng_gt',
                        'new_ng_gt_aero',
                        'old_ng_st',
                        'wind'
                    ]
    
    #returns a list of indices required to sort gens in the order found in gen_order
    gen_sort = map(gens.index, gen_order)
    #actually perform the sort
    data = data[:,gen_sort]
    
    #Compute cumulative power out for each time period to create stacked display
    to_plot = data.cumsum(axis=1)
    if not args.interp:
        #Create "stairsteps"
        to_plot = to_plot.repeat(2,axis=0)
    
    #Establish plot parameters
    if args.gen_set == 'ClustUC':
                    #  o_nuke      coal_lig        coal_sub        o_ccgt      o_nggt      o_ng_st     wind
        color_order = ('yellow',   'Brown',        'Orange',       'blue',     'red',      'white',   'green')
        hatch_order = ('',         '',             '',             '',         '',         'xx',        '')
        opacity     = (0.5,        0.5,            0.5,            0.5,        0.5,        0.5,        0.5)
    else:
                    #   o_nuke    n_nuke      coal_css    n_coal            coal_lig        coal_sub        ng_ccs      n_ccgt      o_ccgt      o_nggt      n_nggt      o_ng_st     wind
        color_order = ('yellow',  'yellow',   '0.25',     'Brown',          'Brown',        'Brown',        'cyan',     'blue',     'blue',     'red',      'red',      'orange',   'green')
        hatch_order = ('x',       '',         '+',        '',               'x',            'x.',           '+',        '',         'x',        'x',        '',         'x',        '')
        opacity     = (0.5,       0.5,        0.5,        0.5,              0.5,            0.5,            0.5,        0.5,        0.5,        0.5,        0.5,        0.5,        0.5)
     
    #Plot it!
    t = np.arange(len(data))
    if not args.interp:
        #Create "stairstep" time values
        t = t.repeat(2)
        t[1::2]+=1
    
    # The following eval converts a command line tuple/list (stored as a string)
    # into a tuple/list. The extra {}'s prevent running any user supplied malicious code
    args.size=eval(args.size,{"__builtins__":None},{})

    fig, ax = plt.subplots(1, facecolor='white', figsize=args.size)
    #
    if args.leg_pos is None:
        ax = plt.subplot2grid((1,7),(0,0),colspan=6)
    #add grid first, our transparency will let it show through
    ax.grid()
    
    #Initialize set of xy points to fill for each polygon. The shape and time data do not change
    #Establish x,y pairs for Polygon
    xy = np.zeros((len(t)*2,2), data.dtype)
    #X positions for top of polygon = increasing time
    xy[range(len(t)),0] = t
    #X positions for bottom of polygon = decreasing time
    xy[range(len(t),len(t)*2),0] = t[::-1]    
    
    #If we are plotting reserves, add filled area for quick start
    if args.rsrv_spin is not None:
        #Note: we reuse the xy time values defined above
        #Y positions for top of polygon = total reserves
        xy[range(len(t)),1] = rsrv_tot
        #Y positions for bottom of polygon = cumulative sum from all gens in reverse area
        xy[range(len(t),len(t)*2),1] = to_plot[::-1, len(gen_order)-1]

        ax.fill(xy[:,0], xy[:,1], label = 'Quick Start',
                    facecolor='purple', linewidth=0, edgecolor='black', alpha=0.5)


    #Plot the filled regions for each generator, go in reverse order so legend order matches
    for g in range(len(gen_order)-1,-1,-1):
        if np.max(data[:,g]) > 0:
            #if g == 0:
            #    lower = 0
            #else:
            #    lower = to_plot[:, g-1]
            #
            #Alternative version as bar plot... MUCH slower b/c dealing with lots
            # of little rectangles
            #ax.bar(t, to_plot[:,g], bottom = lower, label = gen_order[g],
            #    facecolor=color_order[g], linewidth=0, alpha=0.5)

            #Create a dummy rectangle so we get the legend right (fill_between does
            # not show by default
#             dummy = plt.Rectangle((0, to_plot[0, g]),0,data[0, g], label = gen_order[g],
#                             facecolor=color_order[g], edgecolor='none', alpha=0.5, hatch = '//')
#             ax.add_patch(dummy)
#             #Now actually fill the fill_between polygon
#             ax.fill_between(t, lower, to_plot[:,g],
#                             facecolor=color_order[g], edgecolor='none', alpha=0.5)

            #Y positions for top of polygon = cumulative sum
            xy[range(len(t)),1] = to_plot[:,g]
            #Y positions for bottom of polygon = previous cumulative sum in reverse order
            if g == 0:
                xy[range(len(t),len(t)*2),1] = 0
            else:
                xy[range(len(t),len(t)*2),1] = to_plot[::-1, g-1]
            
#             filled_area = plt.Polygon(xy, label = gen_order[g],
#                         facecolor=color_order[g], edgecolor='none', alpha=0.5, hatch = '//')
#             ax.add_patch(filled_area)
            if args.alpha is not None:
                my_alpha = args.alpha
            else:
                my_alpha = opacity[g]

            ax.fill(xy[:,0], xy[:,1], label = gen_order[g],
                        facecolor=color_order[g], linewidth=0, edgecolor='black', alpha=my_alpha, hatch = hatch_order[g])

    #Handle total lines if required
    if not args.interp:
        tot_line_idx = sort.repeat(2)
    else:
        tot_line_idx = sort

    if args.rsrv_spin is None:
        #Now add the demand line (the use of repeat, creates stairsteps)
        if args.tot_dem > 0:
            if args.sort == 'net':
                ax.plot(t, net_demand[tot_line_idx], label='net demand', color='green', alpha=0.75, linewidth=args.tot_dem)
            else:
                ax.plot(t, demand[tot_line_idx], label='demand', color='green', alpha=0.75, linewidth=args.tot_dem)
    else:
        # Show lines for reserves on the plot
        ax.plot(t, rsrv_tot[tot_line_idx], label='Total Reserves', color='blue', linewidth=2)
        ax.plot(t, rsrv_load_and_outage[tot_line_idx], label='Rsv:Outage+Load', color='black', linewidth=2)
        ax.plot(t, rsrv_outage[tot_line_idx], label='Rsv for Outage', color='black', linewidth=2, linestyle='--')
        

    #adjust x range to fit our data length
    lims = list(ax.axis())
    if args.interp:
        lims[1] = len(data)-1;
    else:
        lims[1] = len(data);
    ax.axis(lims)
    

    #And finish off with labels
    if args.title is not None:
    # Use specified title
        ax.set_title(args.title, fontsize=args.font_size)
    else:
    # Or, by default extract bare file name 
        data_name = os.path.basename(pwr_file.name);
        data_name, junk = os.path.splitext(data_name);
        
        ax.set_title(data_name, fontsize=args.font_size)
    
    #Add legend
    # first extract position info
    if args.leg_pos is not None:
        # Clean up input for numeric values
        if args.leg_pos[0]=='(' or (args.leg_pos[0] >='0' and args.leg_pos[0] <= '9'):
            # The following eval converts a command line tuple/list (stored as a string)
            # into a tuple/list. The extra {}'s prevent running any user supplied malicious code
            args.leg_pos=eval(args.leg_pos,{"__builtins__":None},{})
        elif args.leg_pos == 'below':
            #Do nothing, we will handle manually below
            leg_loc = None
            leg_ax_pad = None
        elif isinstance(args.leg_pos, str) or isinstance(args.leg_pos, int):
            # Handle "standard" matplotlib legend placement with number or string
            leg_loc = args.leg_pos
            leg_bb = None
            leg_ax_pad = None
        else:
            # Or use specified bounding box tuple
            leg_loc = None
            leg_bb = args.leg_pos
            leg_ax_pad = None
    else:
        #Default to outside on the right
        leg_loc = 2
        leg_bb = (1.01, 1)
        leg_ax_pad = 0.

    if leg_loc != "Hide":
        if args.leg_pos == 'below':
            #Thanks http://stackoverflow.com/questions/4700614/how-to-put-the-legend-out-of-the-plot
            box = ax.get_position()
            ax.set_position([box.x0, box.y0 + box.height * 0.12,
                             box.width, box.height * 0.85])

            # Put a legend below current axis
            ax.legend(loc='upper center', bbox_to_anchor=(0.48, -0.09),
                      ncol=args.leg_ncol, prop={'size':args.font_size},
                        labelspacing=0.1, borderaxespad=leg_ax_pad,
                        columnspacing=0.3)
        else:
            # spacing in font-size units
            leg=ax.legend(loc=leg_loc, bbox_to_anchor=leg_bb, ncol=args.leg_ncol,
                            labelspacing=0.1, prop={'size':args.font_size}, borderaxespad=leg_ax_pad)

    ax.tick_params(axis='both', which='major', labelsize=args.font_size)

    #Add lines between generator outputs. Do so post legend so they are not included
    if args.lines:
        for g in range(len(gen_order)):
            if g > 0 and not(np.array_equal(to_plot[:, g-1],to_plot[:, g])):
                ax.plot(t, to_plot[:, g], color='black', alpha=0.75, linewidth=0.5)
            
    # Switch to daily ticks for weeks
    if args.daytick:
        ax.set_xticks(np.arange(0,len(t),24))
        ax.set_xticklabels(np.arange(0,len(t),24)/24)
        x_lab_def = "days"
    else:
        x_lab_def = "hours"
    
    if args.xlabel is None:
        ax.set_xlabel(x_lab_def, fontsize=args.font_size)        
    else:
        ax.set_xlabel(args.xlabel, fontsize=args.font_size)

    #Y-axis label
    if args.rsrv_spin is None:
        y_lab_def = 'Power (GW)'
    else:
        y_lab_def = 'Reserve Capacity (GW)'
    
    if args.ylabel is None:
        ax.set_ylabel(y_lab_def, fontsize=args.font_size)        
    else:
        ax.set_ylabel(args.ylabel, fontsize=args.font_size)
        
    #Scale Y axis if desired 
    if args.ymax is not None:
        plt.ylim(ymax=args.ymax)    
    
    #Hide labels if desired
    if args.Xhide:
        ax.set_xticklabels([])
    if args.Yhide:
        ax.set_yticklabels([])
    
    #Now display the results
    fig.show()
        
#-------------------
# handleCommandLine
#-------------------
def handleCommandLine():
    
    
    #Set up command line parser
    p = argparse.ArgumentParser(description='Load duration curves and other plots')
    
    p.add_argument('pwr_files', type=argparse.FileType(mode='rb'), nargs='+', 
                    help='Input file(s) with power production by generator')
    
    p.add_argument('-a', '--alpha', type=float,
                    help='Fill Opacity')
    p.add_argument('-b', '--backend', default='TkAgg', 
                    help='Plotting backend. If unspecified, defaults to TkAgg to use an Agg based backend for fill patterns, etc. Use ''default'' to use the matplotlib default')
    p.add_argument('-d', '--dur', type=int, default=-1, help='Duration in Hours. Use -1 for all')
    p.add_argument('-f', '--first', type=int, default=1, help='First Hour, starting with 1')
    p.add_argument('--font_size', type=int, default=12, help='Font Size')
    p.add_argument('-g', '--gen_set', default='CpUc', 
                    help='Generator set to use for plotting. Options: CpUc (default), ClustUC')
    p.add_argument('-i', '--interp', action="store_true", default=True, 
                    help='Use linear interpolation for smoother curves')
    p.add_argument('-I', '--no_interp', action="store_false", dest='interp', 
                    help='No interpolation, use zero order hold for "stairsteps"')
    p.add_argument('-k', '--daytick', action="store_true", default=False, 
                    help='Xtick by days not hours')
    p.add_argument('-l', '--lines', type=float, default=0.5, 
                    help='Line thickness between generator regions')
    p.add_argument('--leg_ncol', default=1, help='Number of legend columns')
    p.add_argument('-m', '--tot_dem', type=float, default=1, help='Thickness of total demand line')
    p.add_argument('-p', '--leg_pos', 
                    help='Legend Location use 1) matplotlib #/string, 2) "Hide", 3) "below", or 4) bounding box list/tuples: [x,y] or [x,y,width,height] to specify up-right corner using normalized position with origin at low-left of axis. Default outside axis to right')
    p.add_argument('-r', '--rsrv_spin', 
                    help ='Show reserves: use this file for spinning reserves, and gather power & wind from main power file')
    p.add_argument('--ReplaceReserveGW', type=float, default=1.28,
                    help ='Replacement reserve level in GW')
    p.add_argument('-s', '--sort', default= 'time', 
                    choices = ('time','load','net'),
                    help ='Sort order')
    p.add_argument('--SpinReserveLoadFract', type= float, default=0.033, 
                    help ='Additional spinning reserve for load forecast error')
    p.add_argument('--SpinReserveMinGW', type= float, default=2.3, 
                    help ='Spinning resrve for max single contingency')
    p.add_argument('-t', '--title', help='Plot Title (for all plots), default=file name')
    p.add_argument('-w', '--wind_cap_GW', type=float, 
                    help='Total installed wind capacity. Default to max wind power')
    p.add_argument('--WindFlexUpCapacity', type= float, default=0.0795, 
                    help ='Reserves for wind capacity')
    p.add_argument('--WindFlexUpForecast', type= float, default=0.139, 
                    help ='Reserves for wind forecast/power')
    p.add_argument('-x', '--xlabel', help='X-axis label')
    p.add_argument('-X', '--Xhide', action="store_true", default=False, 
                    help='Hide X axis ticks & scale')
    p.add_argument('-y', '--ylabel', help='Y-axis label')
    p.add_argument('-Y', '--Yhide', action="store_true", default=False, 
                    help='Hide Y axis ticks & scale')
    p.add_argument('--ymax', type=float, help='Maximum Y-axis value for consistant vertical scaling')
    p.add_argument('-z', '--size', default=None,
                    help='Figure size (inches) as [width,height] with no spaces')

    
    args = p.parse_args()
    
    #Additional argument processing
    if args.backend != None  and args.backend != 'default':
        matplotlib.use(args.backend)  #Must occur before importing pyplot
    
    global plt                        #Use global so that plt usable in main
    import matplotlib.pyplot as plt   #Must occur after setting backend

    return args


     
if __name__ == '__main__':
    main()

