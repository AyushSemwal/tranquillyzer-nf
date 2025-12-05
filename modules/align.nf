process ALIGN {

    tag "${run_id}"
    label 'cpu'

    cpus params.align_cpus
    container params.container_trq

    input:
    tuple val(run_id), path(work_dir)
    path   reference

    output:
    // Emit BAM path as well as work_dir for downstream processes
    tuple val(run_id), path(work_dir), path("${work_dir}/align/${run_id}.bam")

    script:
    """
    mkdir -p ${work_dir}/align

    # Adapt to your actual Tranquillyzer CLI if different
    tranquillyzer align \\
        ${work_dir} \\
        ${reference} \\
        --output-prefix ${work_dir}/align/${run_id} \\
        --threads ${task.cpus} \\
      > ${work_dir}/align/align.log 2>&1
    """
}