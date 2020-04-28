if Rails.env.development?
  task set_annotation_options: :environment do
    Annotate.set_defaults(models: true, skip_on_db_migrate: true)
  end

  task annotate: :set_annotation_options do
    AnnotateModels.do_annotations(is_rake: true,
                                  model_dir: %w[app/models],
                                  show_indexes: true)
  end

  %w[db:migrate db:migrate:up db:migrate:down db:migrate:reset db:migrate:redo db:rollback].each do |task|
    Rake::Task[task].enhance do
      Rake::Task['annotate'].invoke
      Rake::Task['rubocop:frozen'].invoke
    end
  end
end
