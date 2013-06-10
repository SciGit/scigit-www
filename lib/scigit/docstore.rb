require 'scigit'
require 'scigit/git'
require 'ydocx/document'
require 'fileutils'
require 'tempfile'

module SciGit
  class DocStore
    @@store_dir = SCIGIT_DIR + '/docstore'
    def self.retrieve(project_id, commit_hash, file)
      hash = Git.get_hash(project_id, commit_hash, file)
      if hash.nil?
        return YDocx::ParsedDocument.new
      end
      store_path = File.join(@@store_dir, "r#{project_id}", hash)
      parse_path = File.join(store_path, 'parse.yaml')
      if File.exists?(parse_path)
        YAML::load(File.open(parse_path, 'r'))
      else
        FileUtils.mkdir_p(store_path)
        # Write out the docx file (so ydocx can open it)
        docx = File.open(File.join(store_path, file), 'w')
        docx.close
        Git.show(project_id, commit_hash, file, docx.path)
        doc = YDocx::Document.open(docx.path,
          "/projects/#{project_id}/doc/#{hash}/")
        unless doc.images.empty?
          doc.create_files
        end
        File.open(parse_path, 'w') do |parse|
          parse.write(doc.contents.to_yaml) 
        end
        doc.contents
      end
    end

    def self.get_file(project_id, doc_hash, file)
      path = File.join(@@store_dir, "r#{project_id}", doc_hash, file)
      p path
      if File.exists?(path)
        File.open(path, 'r').read
      else
        return nil
      end
    end
  end
end
