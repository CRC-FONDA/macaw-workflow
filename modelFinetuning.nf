nextflow.enable.dsl=2

process modelFinetuning {
    pod nodeSelector: 'sched=test-ml'
    tag "$month"
    memory '8 GB'
    cpus 6

    container 'fondahub/goce:latest'
    // TODO rename dan wahrscheinlich andere Positionen im tuple
    input:
        tuple val(month), path(string_features_pkl), path(x_all_afterNan), path(y_all_afterNan), path(z_all_afterNan), path(nnh5), path(x_all_columns_small), path(x_all_columns_small_final), path(std_indices_small), path(corr_indices_small), path(std_scaler_small), path(features_fillnan_mean)


    output:
        tuple val(month), path("neuralnet/ml_calibration_GOCE_${month}_${month}_simple_finetune.h5"), emit: 'finetune'

    script:
    """
    interpol_net_goce_simple_finetune.py ${month} ${nnh5}
    """

}