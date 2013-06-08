require_dependency 'scigit'
require_dependency 'scigit/git'
require_dependency 'ydocx/document'
require 'fileutils'
require 'tempfile'

module SciGit
  module DocStore
    @@store_dir = SCIGIT_DIR + '/docstore'
    def self.retrieve(project_id, commit_hash, file)
      hash = Git.get_hash(project_id, commit_hash, file)
      if hash.nil?
        return YDocx::ParsedDocument.new
      end
      commit_hash = Git.get_hash(project_id, commit_hash)
      store_path = File.join(@@store_dir, "r#{project_id}", commit_hash, hash)
      parse_path = File.join(store_path, 'parse.yaml')
      if File.exists?(parse_path)
        YAML::load(File.open(parse_path, 'r'))
      else
        FileUtils.mkdir_p(store_path)
        # Write out the docx file (so ydocx can open it)
        docx = File.open(File.join(store_path, file), 'w')
        docx.close
        Git.show(project_id, commit_hash, file, docx.path)
        doc = YDocx::Document.open(docx.path)
        unless doc.images.empty?
          doc.create_files
        end
        File.open(parse_path, 'w') do |parse|
          parse.write(doc.contents.to_yaml) 
        end
        doc.contents
      end
    end
  end
end
