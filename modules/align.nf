process ALIGN {

    tag "${sample_id}"
    label 'cpu'

    cpus params.align_cpus
    container params.container_trq

    input:
    tuple val(sample_id), path(work_dir)
    path   reference

    output:
    // Emit BAM path as well as work_dir for downstream processes
    tuple val(sample_id), path(work_dir), path("${work_dir}/aligned_files/demuxed_aligned.bam")

    script:
    """
    tranquillyzer align \\
        ${work_dir} \\
        ${reference} \\
        ${work_dir} \\
        --threads ${task.cpus} \\
      > ${work_dir}/align.log 2>&1
    """
}