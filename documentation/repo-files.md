# Stencil Markdown
* data/                                                   # documenting the data used in this project
    * shared/                                             # data shared and committed to the repo
    * unshared/                                           # files stored locally but not shared or committed
        * derived/                                        # files produced from the code we write
        * raw/                                            # files that come from the researcher/client
        * contents.md                                     # description of data/unshared (list of unshared files)
* IALSA-2015-portland-mirror/                             # Copied documents/files from IALSA-2015-Portland
* libs/                                                   # global resources for reports and web
    * css/                                                # customize the appearance of HTML produced by RMarkdown
        * sidebar.css                                     # code of format for styling sheet document
    * images/                                             # portable network graphic (png) images for the conference document reports
        * prototypes/                                     # contains first typical model for the images created for the project
        * prototype_table3.png                            # first typical model of png images to used in the project
        * fisher_z.png                                    # definition and description of fisher's transformation
        * general_model_specification.png                      
        * general_model_specification_0.png
        * general_model_specification_1.png
        * general_model_specification_2.png
        * gsa_poster_logo.png
        * gsa2015banner300.png
        * ialsa_logo_trans.png
        * alsa_logo_white.jpg
        * ialsa_long.png
        * ialsa_small.png
        * issue25_tile_grid_graph.png
        * issue25_tile_grid_graph.png.pdf
        * issue25_tile_grid_graph_0.png
        * model_naming_convention.png
        * model_naming_convention_old.png
        * RandomEffects.png
        * Residuals.png
        * specification_correlation_structure.png
        * specification_covariance_structure.png
        * specification_covariance_structure_noresid.png
        * specification_covariance_structure_old.png
        * specification_covariance_structure2.png
        * table_model_results.png
        * uvic_logo.jpg
* materials/                                              # material for proposed publications outline
    * publication_model/                                  # proposed schemes for publications
        * prototype_table3.ai                             # table format for publications outline
        * publication_model.ai                            # model representation of publication outline
        * publication_model-01.png                        # conventional scheme for reporting and publication
        * publication_model-02.png                        # conventional scheme for reporting and publication
    * LGM_Mplus_primer.pdf                                # Coding format on mplus
    * Mplus_muniz.pdf                                     # guidelines on conference preparation
    * naming_convention.pptx                              # naming convention for models
    * test.png                                            # symbol representation of residuals by gender
    * thumbs.db                                           # reorganizing folders
* playgrounds/                                            # files that test our ideas
    * regex_study_paths                                   # regular expression code example to extract text
* projects/                                               # publication scheme for the project
    * cognitive/                                          # resources for the cognitive project
        * table_2_ISR/                                    # interpretation of ISR correlation
    * gait/                                               # resources for the gait project
        * table_2_ISR/                                    # Interpretation of ISR correlations
    * github_labels.md                                    # markdown of labels
    * grip/                                               # project summary of "grip and cognitive function"
        * BISR/                                           # interpreting BISR: grip and cognitive function 
            *bisr_eas.md                                  # verbal interpretation of bivariate ISR correlation in eas study
* manuscript/                                             # physical proofs of manuscripts
    * submitted manuscript. pdf                           # physcial manuscript of coordinated analysis on age-related changes in physical capabilities
* physical/                                               # particulars on studies, studying physical measures
    * announce.md                                         # agenda for the physical track
    * catalog.md                                          # Listing physical outcomes each study has to contribute
    * issues/                                             # issues related to physical outcomes by study
        * se(corr)/                                       # png images depicting study model problems
            * problem_models.png                          # image #1 of the same
            * problem_models_small.png                    # image #2 of the same
* physical-cognitive/                                     # particulars on studies, studying cognitive measures
    * gsa_poster.md                                       # Markdown on poster studying multivariate change in physical and cognitive functioning
    * images/                                             # images picked for poster studying multivariate change in physical and cognitive functioning
        * gsa_poster_qrcode.png                           # logo image for the poster studying multivariate change in physical and cognitive functioning
        * gsa_poster_table.png                            # png of table depicting bivariate relationships between physical and cognitive measures
        * qr_handout.pdf                                  # pdf of logo images
* pulmonary/                                              # pulmonary function and cognition
    * BISR/                                               # verbal interpretations of bivariate correlations between pulmonary function and cognition
        * bisr_eas.md                                     # Verbal interpretation of graph studying bisr for eas study
        * bisr_elsa.md                                    # Verbal interpretation of graph studying bisr for elsa study
        * bisr_hrs.md                                     # Verbal interpretation of graph studying bisr for hrs study
        * bisr_ilse.md                                    # Verbal interpretation of graph studying bisr for ilse study
        * bisr_nas.md                                     # Verbal interpretation of graph studying bisr for nas study
        * bisr_nuage.md                                   # Verbal interpretation of graph studying bisr for nuage study
        * bisr_octo.md                                    # Verbal interpretation of graph studying bisr for octo study
        * bisr_radc.md                                    # Verbal interpretation of graph studying bisr for radc study
        * bisr_satsa.md                                   # Verbal interpretation of graph studying bisr for satsa study
* table_1_descriptive/                                    # describe sample characteristics of each study
* projects/ 											  # official dynamic reports, must maintain in good shape all the time
* sandbox/                                                # dynamic reports in the making, experiment, not afraid to lose, or care to support
    * basic/                                              # basic quantifications
    * descriptives/                                       # experiementing with various quantificatio.

	
    * dev/                                                # scripts for correcting the output files names and making the reports look presentable
        * 1a_correct_model_names.R                        # this script corrects irregularities in the naming of the output files
        * x_make_pretty.R                                 # make the data look presentable for reporting
    * graphs/                                             # contains R code for outputting graphs
        * kb_profiles_functions.R                         # R code to contruct graph depicting relationships between physical measures and congnitive measures and theircovariates. 
        * main_theme.R                                    # main themes for graphs
    * mplus/  
        * prototype/                                      # folder contains files on prototype code for modeling cognitive measures; in different file extensions
            * new_b1_male_a_grip_categories_18.dgm        # modeling cognitive measures in males
            * new_b1_male_a_grip_categories_18.gh5        # modeling cognitive measures in males; gh5 file containing Mplus data in HDF5 format
            * new_b1_male_a_grip_categories_18.inp        # modeling cognitive measures in males; input file extension
            * new_b1_male_a_grip_categories_18.out        # modeling cognitive measures in males; output file extension
            * prototype_b1_male_a_grip_categories_18.inp  # prototype code for modeling cognitve measures in males; input file extension 
            * prototype_b1_RADC.inp                       # modeling cognitive measures; input file extension
    * extraction_functions.R                              # extract the basic indicators about the model
    * functions_to_generate_Mplus_scripts.R               # r code/functions to generate mplus scripts 
    * generate_run_graph.R                                # generating scripts to process mplus data
    * group_variables.R                                   # load the objects that will subset columns from the results tables
    * look-at-data.R                                      # functions to look at data and export it back to mplus
* utility/                                                # files indirectly contributing to data manipulation and analysis
    * install-packages.R                                  # code for required packages for efficient repo operation
    * package-dependency-list.csv                         # elements necessary for packages fuctionality
    * reproduce.R                                         # code for reproducible research
* .gitignore                                              # files that dont need sharing on GitHub
* ialsa-2015-portland-stencil.Rproj                       # R plateform for stencil coding
* LICENSE                                                 # copyright to the software
* repo-files.md                                           # file structure directory
