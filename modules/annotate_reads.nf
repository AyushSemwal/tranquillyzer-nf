process ANNOTATE_READS {

    tag "${run_id}"
    label 'gpu'

    cpus params.annotate_cpus
    container params.container_trq

    input:
    tuple val(run_id), path(work_dir)
    path   metadata
    path   seq_orders
    val    model_name
    val    model_type
    val    chunk_size
    val    bc_lv_threshold
    val    gpu_mem

    output:
    // Still emitting run_id + work_dir; internal contents updated
    tuple val(run_id), path(work_dir)

    script:
    """
    mkdir -p ${work_dir}/annotate

    tranquillyzer annotate-reads \\
        ${work_dir} \\
        ${metadata} \\
        --model-name ${model_name} \\
        --output-fmt fastq \\
        --gpu-mem ${gpu_mem} \\
        --model-type ${model_type} \\
        --seq-order-file ${seq_orders} \\
        --chunk-size ${chunk_size} \\
        --bc-lv-threshold ${bc_lv_threshold} \\
        --threads ${task.cpus} \\
      > ${work_dir}/annotate/annotate_reads.log 2>&1
    """
}