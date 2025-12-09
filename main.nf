#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    tranquillyzer-nf: A Nextflow pipeline for processing 
    long-read single-cell RNA-seq / bulk RNA-seq using Tranquillyzer for 
    annotation, barcode correction, alignment, and duplicate marking.

    Phase 1: preprocess → read length QC → annotate → align → duplicate marking
    
    Later extensions:
    - feature counts
    - QC metrics

    GitHub : https://github.com/huishenlab/tranquillyzer.git
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Import module processes
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { PREPROCESS          } from './modules/preprocess.nf'
include { READ_LENGTH_DIST_QC } from './modules/read_length_dist_qc.nf'
include { ANNOTATE_READS      } from './modules/annotate_reads.nf'
include { ALIGN               } from './modules/align.nf'
include { DEDUP               } from './modules/dedup.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Channels
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

run_ch = Channel
  .fromPath(params.sample_sheet)
  .splitCsv(header: true, sep: '\t')
  .map { row ->
      tuple(
        row.sample_id,
        file(row.raw_dir),
        file(row.work_dir),
        file(row.metadata)
      )
  }

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Workflow definition
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {

    // 1) Preprocess
    preprocessed_ch = PREPROCESS(run_ch)

    // 2) Read-length distribution QC
    read_length_dist_ch = READ_LENGTH_DIST_QC(preprocessed_ch)

    // 3) Annotate reads (GPU)
    annotated_ch = ANNOTATE_READS(
        preprocessed_ch,
        params.model_name,
        params.model_type,
        params.chunk_size,
        params.bc_lv_threshold,
        params.gpu_mem
    )

    // 4) Align
    aligned_ch = ALIGN(
        annotated_ch,
        file(params.reference)
    )

    // 5) Duplicate marking
    dedup_ch = DEDUP(
        aligned_ch
    )

    // Emit final deduplicated BAMs / output dirs
    dedup_ch.view { it -> "DEDUP DONE: ${it}" }
}