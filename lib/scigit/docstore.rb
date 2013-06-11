require 'scigit'
require 'scigit/git'
require 'ydocx/document'
require 'fileutils'
require 'tempfile'
require 'digest'

module SciGit
  class DocStore
    @@store_dir = SCIGIT_DIR + '/docstore'
    def self.retrieve(project_id, commit_hash, file)
      hash = Git.get_hash(project_id, commit_hash, file)
      if hash.nil?
        return YDocx::ParsedDocument.new
      end
      store_path = File.join(@@store_dir, "r#{project_id}", hash)
      parse_path = File.join(store_path, 'parse.bin')
      if File.exists?(parse_path)
        begin
          return Marshal.load(File.open(parse_path, 'r'))
        rescue
          # continue to reparsing
        end
      end
      FileUtils.mkdir_p(store_path)
      # Write out the docx file (so ydocx can open it)
      docx = File.open(File.join(store_path, file), 'w')
      docx.close
      Git.show(project_id, commit_hash, file, docx.path)
      doc = YDocx::Document.open(docx.path,
        "/projects/#{project_id}/doc/#{hash}/")
      # Pre-compute hashes for faster diffing
      doc.contents.hash
      unless doc.images.empty?
        doc.create_files
      end
      File.open(parse_path, 'w') do |parse|
        Marshal.dump(doc.contents, parse)
      end
      doc.contents
    end

    def self.retrieve_diff(project_id, old_hash, new_hash, file)
      hash1 = Git.get_hash(project_id, old_hash, file)
      hash2 = Git.get_hash(project_id, new_hash, file)
      store_path = File.join(@@store_dir, "r#{project_id}", hash1 || 'dev_null', 'diff')
      diff_path = File.join(store_path, (hash2 || 'dev_null') + '.bin')
      if File.exists?(diff_path)
        begin
          return Marshal.load(File.open(diff_path, 'r'))
        rescue
          # continue and re-diff
        end
      end

      FileUtils.mkdir_p(store_path)
      doc1 = DocStore.retrieve(project_id, old_hash, file)
      doc2 = DocStore.retrieve(project_id, new_hash, file)
      diff = YDocx::Differ.new.diff(doc1, doc2)
      File.open(diff_path, 'w') do |diff_file|
        Marshal.dump(diff, diff_file)
      end
      diff
    end

    def self.get_file(project_id, doc_hash, file)
      path = File.join(@@store_dir, "r#{project_id}", doc_hash, file)
      if File.exists?(path)
        File.open(path, 'r').read
      else
        return nil
      end
    end
  end
end
