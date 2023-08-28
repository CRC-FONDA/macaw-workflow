nextflow.enable.dsl=2

process modelTraining {
    pod nodeSelector: 'sched=test-ml'
    memory '124 GB'
    cpus 31

    container 'fondahub/goce:latest'

    input:
        path("*")
        val months


    output:
        path("std_indices_small.pkl"), emit: 'std_indices_small'
        path("corr_indices_small.pkl"), emit: 'corr_indices_small'
        path("std_scaler_small.pkl"), emit: 'std_scaler_small'
        path("config_goce/GOCE/??????_??????/x_all_columns_small.pkl"), emit: 'x_all_columns_small'
        path("config_goce/GOCE/??????_??????/x_all_columns_small_final.pkl"), emit: 'x_all_columns_small_final'
        path("neuralnet/ml_calibration_GOCE_??????_??????_simple.h5"), emit: 'nnh5'

    script:
    """
    interpol_net_goce_simple.py ${months.join(" ")}
    """
    // interpol_net_goce_simple.py -m memory_profiler ${months.join(" ")}

}