nextflow.enable.dsl=2

process publicationCDF {
    pod nodeSelector: 'sched=test-ml'
    tag "$month"
    publishDir 'output', mode: 'copy', pattern: '**.cdf'

    memory '10 GB'
    cpus 2

    container 'fondahub/goce:latest'
    // TODO rename dan wahrscheinlich andere Positionen im tuple
    input:
        tuple val(month), path(finetune), path(std_indices_small), path(corr_indices_small), path(std_scaler_small), path(x_all_columns_small), path(x_all_columns_small_final), path(x_all_afterNan), path(y_all_afterNan), path(z_all_afterNan), path(string_features), path(features_fillnan_mean)
        file (templateAlignCorr)
        file (templateApex)
        file (templateChaos)
        file (templateRaw)

    output:
        path("GOCE/cal/calcorr/go_fgm_cdf_platmag_v0204*"), emit: 'cdfs'

    script:
    """
    publication_write_cdf_files_goce_simple.py ${month} ${finetune}
    """

}