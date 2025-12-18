process SPLIT_BAM {

    tag "${sample_id}"
    label 'cpu'

    cpus params.split_bam
    container params.container_trq
    val bucket_threads = params.bucket_threads
    val merge_threads = params.merge_threads
    val max_open_cb_writers = params.max_open_cb_writers

    input:
    tuple val(sample_id), path(work_dir), path(dup_marked_bam)

    output:
    tuple val(sample_id), path(work_dir), path("${work_dir}/aligned_files/split_bams")

    script:
    """
    mkdir -p ${work_dir}/aligned_files
    # Adapt to your actual Tranquillyzer CLI as needed
    tranquillyzer split-bams \\
        ${dup_marked_bam} \\
        --output-dir ${work_dir}/aligned_files/split_bams \\
        --bucket-threads ${task.bucket_threads} \\
        --merge-threads ${task.merge_threads} \\
        --max-open-cb-writers ${params.max_open_cb_writers} \\
      > ${work_dir}/split_bam.log 2>&1
    """
}