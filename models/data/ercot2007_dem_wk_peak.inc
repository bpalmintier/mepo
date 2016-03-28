
$ontext
-----------------------------------------------------
Sequential Hourly Demand data for ONE WEEK ONLY.
For ERCOT for use with The Advanced Power family of models

  This data was created using: ERCOT_2007_Hourly_Wind&Load_GAMS_formatter.xlsx (SVN v379M)
  Actual recorded data from ERCOT POI page: 
    http://planning.ercot.com/data/hourly-windoutput/2007/
  
  Data from the week starting: Saturday 2007-Aug-12 (8/12/2007)
  Which contains both the PEAK DEMAND

  When pasting from Excel, convert tabs to spaces using a tabstop of 12

 originally coded in GAMS by Bryan Palmintier 2010-03-30

History:
Ver   Date       Time  Who            What
---  ----------  ----- -------------- ---------------------------------
  1  2011-10-14  01:15  bpalmintier   Adapted from ieee_rts96_dem_wk v1
  2  2011-10-14  11:45  bpalmintier   Updated to use hour of year block names for availability subset matching
  3  2012-02-07  21:05  bpalmintier   Scaled from MW to GW
  4  2012-05-04  11:55  bpalmintier   Adapted for separate blocks (B) and time sub-periods (T)
-----------------------------------------------------
$offtext

* Declare the actual set members (blocks, hours, etc) and add hr_of_yr cross reference
sets
    DEM_PARAMS  "demand block table parameters from load duration curve"
       /
        avail_idx   "corresponding hour of the year index for avail lookup"
        dur         "duration of block                 [hrs]"
        power       "average power demand during block [GW]"
       /

    B           "Demand blocks (e.g. weeks or ldc)"
        /wk/
    T           "Demand time sub-periods (e.g. hours or ldc sub-blocks)"
        /t001*t168/
;

* The actual demand data table:
table    pDemandData(B, T, DEM_PARAMS)   "Demand data"
            avail_idx   dur         power
*           [#]         [hr]        [GW]
wk.t001     5352        1           41.525
wk.t002     5353        1           38.597
wk.t003     5354        1           36.299
wk.t004     5355        1           34.914
wk.t005     5356        1           33.663
wk.t006     5357        1           33.057
wk.t007     5358        1           32.937
wk.t008     5359        1           32.617
wk.t009     5360        1           34.052
wk.t010     5361        1           38.064
wk.t011     5362        1           42.287
wk.t012     5363        1           46.694
wk.t013     5364        1           50.565
wk.t014     5365        1           53.570
wk.t015     5366        1           55.821
wk.t016     5367        1           57.444
wk.t017     5368        1           57.964
wk.t018     5369        1           57.927
wk.t019     5370        1           57.158
wk.t020     5371        1           55.487
wk.t021     5372        1           53.141
wk.t022     5373        1           52.374
wk.t023     5374        1           49.101
wk.t024     5375        1           44.921
wk.t025     5376        1           41.167
wk.t026     5377        1           38.359
wk.t027     5378        1           36.423
wk.t028     5379        1           35.280
wk.t029     5380        1           34.715
wk.t030     5381        1           34.955
wk.t031     5382        1           36.792
wk.t032     5383        1           38.234
wk.t033     5384        1           39.539
wk.t034     5385        1           42.929
wk.t035     5386        1           46.996
wk.t036     5387        1           51.759
wk.t037     5388        1           55.542
wk.t038     5389        1           58.710
wk.t039     5390        1           60.851
wk.t040     5391        1           61.919
wk.t041     5392        1           61.990
wk.t042     5393        1           61.355
wk.t043     5394        1           60.349
wk.t044     5395        1           58.313
wk.t045     5396        1           55.839
wk.t046     5397        1           54.667
wk.t047     5398        1           50.845
wk.t048     5399        1           46.603
wk.t049     5400        1           42.031
wk.t050     5401        1           39.145
wk.t051     5402        1           36.943
wk.t052     5403        1           35.628
wk.t053     5404        1           34.916
wk.t054     5405        1           35.263
wk.t055     5406        1           36.583
wk.t056     5407        1           37.861
wk.t057     5408        1           39.040
wk.t058     5409        1           42.111
wk.t059     5410        1           46.022
wk.t060     5411        1           50.403
wk.t061     5412        1           53.888
wk.t062     5413        1           56.894
wk.t063     5414        1           59.286
wk.t064     5415        1           60.694
wk.t065     5416        1           61.417
wk.t066     5417        1           61.209
wk.t067     5418        1           60.345
wk.t068     5419        1           58.265
wk.t069     5420        1           55.821
wk.t070     5421        1           54.904
wk.t071     5422        1           51.458
wk.t072     5423        1           47.493
wk.t073     5424        1           42.701
wk.t074     5425        1           39.710
wk.t075     5426        1           37.774
wk.t076     5427        1           36.325
wk.t077     5428        1           35.508
wk.t078     5429        1           35.519
wk.t079     5430        1           37.182
wk.t080     5431        1           38.825
wk.t081     5432        1           39.847
wk.t082     5433        1           42.541
wk.t083     5434        1           46.156
wk.t084     5435        1           50.001
wk.t085     5436        1           53.678
wk.t086     5437        1           56.195
wk.t087     5438        1           57.698
wk.t088     5439        1           58.433
wk.t089     5440        1           58.964
wk.t090     5441        1           58.296
wk.t091     5442        1           56.710
wk.t092     5443        1           54.579
wk.t093     5444        1           52.801
wk.t094     5445        1           52.079
wk.t095     5446        1           49.060
wk.t096     5447        1           44.826
wk.t097     5448        1           41.052
wk.t098     5449        1           38.510
wk.t099     5450        1           36.664
wk.t100     5451        1           35.261
wk.t101     5452        1           34.765
wk.t102     5453        1           35.055
wk.t103     5454        1           36.808
wk.t104     5455        1           38.357
wk.t105     5456        1           39.113
wk.t106     5457        1           40.770
wk.t107     5458        1           43.250
wk.t108     5459        1           45.502
wk.t109     5460        1           47.060
wk.t110     5461        1           48.169
wk.t111     5462        1           49.605
wk.t112     5463        1           50.446
wk.t113     5464        1           51.409
wk.t114     5465        1           51.252
wk.t115     5466        1           50.513
wk.t116     5467        1           48.819
wk.t117     5468        1           47.804
wk.t118     5469        1           47.053
wk.t119     5470        1           44.573
wk.t120     5471        1           41.166
wk.t121     5472        1           38.038
wk.t122     5473        1           35.949
wk.t123     5474        1           34.625
wk.t124     5475        1           33.621
wk.t125     5476        1           33.193
wk.t126     5477        1           33.886
wk.t127     5478        1           35.912
wk.t128     5479        1           37.956
wk.t129     5480        1           39.001
wk.t130     5481        1           41.255
wk.t131     5482        1           43.748
wk.t132     5483        1           46.539
wk.t133     5484        1           49.152
wk.t134     5485        1           51.310
wk.t135     5486        1           53.576
wk.t136     5487        1           54.409
wk.t137     5488        1           53.870
wk.t138     5489        1           52.606
wk.t139     5490        1           50.946
wk.t140     5491        1           48.263
wk.t141     5492        1           46.402
wk.t142     5493        1           45.669
wk.t143     5494        1           43.749
wk.t144     5495        1           40.875
wk.t145     5496        1           38.007
wk.t146     5497        1           36.008
wk.t147     5498        1           34.551
wk.t148     5499        1           33.422
wk.t149     5500        1           32.787
wk.t150     5501        1           32.739
wk.t151     5502        1           33.454
wk.t152     5503        1           34.312
wk.t153     5504        1           35.603
wk.t154     5505        1           38.597
wk.t155     5506        1           41.388
wk.t156     5507        1           44.345
wk.t157     5508        1           46.839
wk.t158     5509        1           48.399
wk.t159     5510        1           49.057
wk.t160     5511        1           49.651
wk.t161     5512        1           50.058
wk.t162     5513        1           50.010
wk.t163     5514        1           48.977
wk.t164     5515        1           47.468
wk.t165     5516        1           46.320
wk.t166     5517        1           46.054
wk.t167     5518        1           44.057
wk.t168     5519        1           41.208
;
