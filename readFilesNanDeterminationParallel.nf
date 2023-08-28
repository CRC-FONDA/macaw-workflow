nextflow.enable.dsl=2

process readFilesNanDeterminationParallel {
    pod nodeSelector: 'sched=test-ml'
    tag "$month"
    cpus    1
    memory { 12.GB * task.attempt }
    errorStrategy 'retry'

    container 'fondahub/goce:latest'

    input:
    // TODO auf tuples umstellen
        tuple val(month), path(x_all), path(y_all), path(z_all), path(string_features)

    output:
    // TODO auf tuples umstellen
    tuple val(month), path('??????_x_column_to_count.pickle'),path('??????_x_column_to_mean.pickle'), path('??????_x_overall.pickle'), path('??????_z_column_to_count.pickle'),path('??????_z_column_to_mean.pickle'),path('??????_z_overall.pickle'), emit: 'x_column_to_count'

    script:
    """
    echo ${x_all}
    read_files_nan_determination_parallel.py ${x_all} ${y_all} ${z_all} ${string_features}
    """

}