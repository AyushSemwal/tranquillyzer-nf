process ANNOTATE_READS {

    tag "${sample_id}"
    label 'gpu'

    cpus params.annotate_cpus
    container params.container_trq

    input:
    tuple val(sample_id), path(work_dir), path(metadata)
    path   seq_orders
    val    model_name
    val    model_type
    val    chunk_size
    val    bc_lv_threshold
    val    gpu_mem

    output:
    tuple val(sample_id), path(work_dir)

    script:
    def output_fmt = params.output_fastq ? 'fastq' : 'fasta'

    """
    mkdir -p ${work_dir}/annotate

    tranquillyzer annotate-reads \\
        ${work_dir} \\
        ${metadata} \\
        --model-name ${model_name} \\
        --output-fmt ${output_fmt} \\
        --gpu-mem ${gpu_mem} \\
        --model-type ${model_type} \\
        --seq-order-file ${seq_orders} \\
        --chunk-size ${chunk_size} \\
        --bc-lv-threshold ${bc_lv_threshold} \\
        --threads ${task.cpus} \\
      > ${work_dir}/annotate_reads.log 2>&1
    """
}