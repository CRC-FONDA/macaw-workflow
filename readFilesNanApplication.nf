nextflow.enable.dsl=2

process readFilesNanApplication {
    pod nodeSelector: 'sched=test-ml'
    tag "$month"
    cpus    1
    memory { 16.GB * task.attempt }
    errorStrategy 'retry'

    container 'fondahub/goce:latest'

    input:
       tuple val(month), path(x_all), path(y_all), path(z_all), path(string_features), file(features_to_drop), file(features_fillnan_mean)
       

    output:
        tuple val(month), path('??????_x_all_afterNan.h5'), path('??????_y_all_afterNan.h5'), path('??????_z_all_afterNan.h5'), emit: afterNan


    script:
    """
    echo ${x_all}
    echo ${y_all}
    read_files_nan_application.py ${x_all} ${y_all} ${z_all} ${string_features} ${features_to_drop} ${features_fillnan_mean}
    """

}