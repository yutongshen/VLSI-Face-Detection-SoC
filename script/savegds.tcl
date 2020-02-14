setStreamOutMode -specifyViaName default \
                 -SEvianames false \
                 -virtualConnection false \
                 -uniquifyCellNamesPrefix false \
                 -snapToMGrid false \
                 -textSize 1 \
                 -version 3

streamOut ../pr/top_pr.gds \
          -mapFile /usr/cad/CBDK/CBDK018_UMC_Faraday_v1.0/CIC/SOCE/streamOut.map \
          -merge { /usr/cad/CBDK/CBDK018_UMC_Faraday_v1.0/CIC/Phantom/fsa0m_a_generic_core_cic.gds \
                   /usr/cad/CBDK/CBDK018_UMC_Faraday_v1.0/CIC/Phantom/FSA0M_A_GENERIC_CORE_ANT_V55_cic.gds \
                   ../sim/SRAM/SRAM.gds } \
          -stripes 1 -units 1000 -mode ALL
