nextflow.enable.dsl=2

include { readFilesPandas } from './readFilesPandas.nf'
include { readFilesNanDeterminationParallel } from './readFilesNanDeterminationParallel.nf'
include { readFilesNanDeterminationParallelMerge } from './readFilesNanDeterminationParallelMerge.nf'
include { readFilesNanApplication } from './readFilesNanApplication.nf'
include { modelTraining } from './modelTraining.nf'
include { modelFinetuning } from './modelFinetuning.nf'
include { publicationCDF } from './publicationCDF.nf'


//Main workflow
workflow {

    data = Channel
    .fromFilePairs('inputdata/{GO_data,GO_rawdata,GO_rawdata_hk,GO_rawdata_telemetry}_*.h5', size: 4){ file ->
    String s = file.toString().split("_")[file.toString().split("_").length -1].split("\\.")[0]
    return s }.filter { file ->
     if(true) {
        return true
     } else {
     return false

     }
     }

    orbit_counter_path = file( "inputdata/Zusatzdateien/GO_ORBCNT_20090317T231001_20131109T234516_0101.h5" )
    kp_dst_path = file("inputdata/Zusatzdateien/all_kp_dst_indices_v2.lst")
    lib64tmioc = file("inputdata/Zusatzdateien/lib64tmioc.so")
    leadpsec = file("inputdata/Zusatzdateien/LEAPSEC.dat")

    templateAlignCorr = file("inputdata/templates/template_aligncal_corr_v0204.cdf")
    templateApex = file("inputdata/templates/template_apex_v0204.cdf")
    templateChaos = file("inputdata/templates/template_chaos7_v0204.cdf")
    templateRaw = file("inputdata/templates/template_raw_v0204.cdf")



    readFilesPandas(data, orbit_counter_path, kp_dst_path, lib64tmioc,leadpsec)



    readFilesPandasOutput = readFilesPandas.out

    readFilesNanDeterminationParallel(readFilesPandasOutput)

    files_column_to_count = readFilesNanDeterminationParallel.out.map{it.subList(1, it.size()) }.flatten().buffer( size: Integer.MAX_VALUE, remainder: true )

    months_column_to_count = readFilesNanDeterminationParallel.out.map{it[0] }.flatten().buffer( size: Integer.MAX_VALUE, remainder: true )

    readFilesNanDeterminationParallelMerge(files_column_to_count, months_column_to_count)

    inputReadFilesNanApplication = readFilesPandasOutput.combine(readFilesNanDeterminationParallelMerge.out.features_to_drop).combine(readFilesNanDeterminationParallelMerge.out.features_fillnan_mean)

    readFilesNanApplication(inputReadFilesNanApplication)

    inputFedLearnWorker = readFilesNanApplication.out.join(readFilesPandasOutput).map{it.subList(1, it.size()) }.flatten().filter{!it.toString().contains("all.h5")}.toList()

    monthsForNN = readFilesNanApplication.out.map{it[0] }.flatten().buffer( size: Integer.MAX_VALUE, remainder: true )
    nanFiles = readFilesNanApplication.out.map{it.subList(1, it.size()) }.flatten().buffer( size: Integer.MAX_VALUE, remainder: true )


    modelTraining(inputFedLearnWorker,monthsForNN)

    monthNNTuple = readFilesPandasOutput.map{ it[0,4] }.join(readFilesNanApplication.out.combine(modelTraining.out.nnh5).combine(modelTraining.out.x_all_columns_small).combine(modelTraining.out.x_all_columns_small_final)
                                                        .combine(modelTraining.out.std_indices_small).combine(modelTraining.out.corr_indices_small).combine(modelTraining.out.std_scaler_small).combine(readFilesNanDeterminationParallelMerge.out.features_fillnan_mean))

    monthNNTuple = monthNNTuple.filter( tuple -> !tuple[0].contains("201108"))


    modelFinetuning(monthNNTuple)

    publicationInput = modelFinetuning.out.combine(modelTraining.out.std_indices_small).combine(modelTraining.out.corr_indices_small).combine(modelTraining.out.std_scaler_small).combine(modelTraining.out.x_all_columns_small).combine(modelTraining.out.x_all_columns_small_final)
                       .join(readFilesNanApplication.out).join(readFilesPandasOutput.map{ it[0,4] }).combine(readFilesNanDeterminationParallelMerge.out.features_fillnan_mean)

    publicationInput.view()

    publicationCDF(publicationInput,templateAlignCorr, templateApex, templateChaos, templateRaw )

}