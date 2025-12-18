nextflow.enable.dsl = 2

include { PREPROCESS          } from '../modules/preprocess'
include { READ_LENGTH_DIST_QC } from '../modules/read_length_dist_qc'
include { ANNOTATE_READS      } from '../modules/annotate_reads'
include { ALIGN               } from '../modules/align'
include { DEDUP               } from '../modules/dedup'

workflow TRANQUILLYZER_PIPELINE {

    take:
    run_ch   // channel emitting (sample_id, raw_dir, work_dir, metadata)

    main:

    preprocessed_ch = PREPROCESS(run_ch)

    qc_ch = READ_LENGTH_DIST_QC(preprocessed_ch)

    annotated_ch = ANNOTATE_READS(
        qc_ch,
        params.model_name,
        params.model_type,
        params.chunk_size,
        params.bc_lv_threshold,
        params.gpu_mem
    )

    aligned_ch = ALIGN(
        annotated_ch,
        file(params.reference)
    )

    dedup_ch = DEDUP(aligned_ch)

    // Produce a stable “final output contract”
    final_outputs = dedup_ch

    emit:
    final_outputs
}