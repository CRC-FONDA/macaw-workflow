nextflow.enable.dsl=2

process readFilesNanDeterminationParallelMerge {
    pod nodeSelector: 'sched=test-ml'
    memory '1 GB'
    cpus    1

    container 'fondahub/goce:latest'

    input:
        path("*")
        val months



    output:
        path 'features_to_drop.pkl', emit: 'features_to_drop'
        path 'features_fillna_mean.pkl', emit: 'features_fillnan_mean'

    script:
    """
    read_files_nan_determination_parallel_merge.py ${months.join(" ")}
    """

}