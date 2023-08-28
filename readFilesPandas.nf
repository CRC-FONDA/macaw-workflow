nextflow.enable.dsl=2

process readFilesPandas {
    pod nodeSelector: 'sched=test-ml'
    tag "$month"
    memory '12 GB'
    cpus    1

    container 'fondahub/goce:latest'

    input:
        tuple val(month), file(reads)
        file orbit_counter_path
        file kp_dst_path
        file lib64tmioc
        file leadpsec

    output:
    tuple val(month), path("*/${month}_x_all.h5"), path("*/${month}_y_all.h5"), path("*/${month}_z_all.h5"), path("config_goce/${month}_string_features.pkl"), emit: x_all

    script:
    """
    echo ${orbit_counter_path}
    echo ${reads}
    read_files_pandas.py ${orbit_counter_path} ${kp_dst_path} ${reads} ${lib64tmioc} ${leadpsec}
    """

}