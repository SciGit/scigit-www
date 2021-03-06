#
# Autogenerated by Thrift Compiler (0.8.0)
#
# DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
#

require 'thrift'
require 'scigit/thrift_types'

module RepositoryManager
  class Client
    include ::Thrift::Client

    def addPublicKey(keyId, userId, publicKey)
      send_addPublicKey(keyId, userId, publicKey)
      recv_addPublicKey()
    end

    def send_addPublicKey(keyId, userId, publicKey)
      send_message('addPublicKey', AddPublicKey_args, :keyId => keyId, :userId => userId, :publicKey => publicKey)
    end

    def recv_addPublicKey()
      result = receive_message(AddPublicKey_result)
      return
    end

    def deletePublicKey(keyId, userId, publicKey)
      send_deletePublicKey(keyId, userId, publicKey)
      recv_deletePublicKey()
    end

    def send_deletePublicKey(keyId, userId, publicKey)
      send_message('deletePublicKey', DeletePublicKey_args, :keyId => keyId, :userId => userId, :publicKey => publicKey)
    end

    def recv_deletePublicKey()
      result = receive_message(DeletePublicKey_result)
      return
    end

    def createRepository(repositoryId)
      send_createRepository(repositoryId)
      recv_createRepository()
    end

    def send_createRepository(repositoryId)
      send_message('createRepository', CreateRepository_args, :repositoryId => repositoryId)
    end

    def recv_createRepository()
      result = receive_message(CreateRepository_result)
      return
    end

    def deleteRepository(repositoryId)
      send_deleteRepository(repositoryId)
      recv_deleteRepository()
    end

    def send_deleteRepository(repositoryId)
      send_message('deleteRepository', DeleteRepository_args, :repositoryId => repositoryId)
    end

    def recv_deleteRepository()
      result = receive_message(DeleteRepository_result)
      return
    end

  end

  class Processor
    include ::Thrift::Processor

    def process_addPublicKey(seqid, iprot, oprot)
      args = read_args(iprot, AddPublicKey_args)
      result = AddPublicKey_result.new()
      @handler.addPublicKey(args.keyId, args.userId, args.publicKey)
      write_result(result, oprot, 'addPublicKey', seqid)
    end

    def process_deletePublicKey(seqid, iprot, oprot)
      args = read_args(iprot, DeletePublicKey_args)
      result = DeletePublicKey_result.new()
      @handler.deletePublicKey(args.keyId, args.userId, args.publicKey)
      write_result(result, oprot, 'deletePublicKey', seqid)
    end

    def process_createRepository(seqid, iprot, oprot)
      args = read_args(iprot, CreateRepository_args)
      result = CreateRepository_result.new()
      @handler.createRepository(args.repositoryId)
      write_result(result, oprot, 'createRepository', seqid)
    end

    def process_deleteRepository(seqid, iprot, oprot)
      args = read_args(iprot, DeleteRepository_args)
      result = DeleteRepository_result.new()
      @handler.deleteRepository(args.repositoryId)
      write_result(result, oprot, 'deleteRepository', seqid)
    end

  end

  # HELPER FUNCTIONS AND STRUCTURES

  class AddPublicKey_args
    include ::Thrift::Struct, ::Thrift::Struct_Union
    KEYID = 1
    USERID = 2
    PUBLICKEY = 3

    FIELDS = {
      KEYID => {:type => ::Thrift::Types::I32, :name => 'keyId'},
      USERID => {:type => ::Thrift::Types::I32, :name => 'userId'},
      PUBLICKEY => {:type => ::Thrift::Types::STRING, :name => 'publicKey'}
    }

    def struct_fields; FIELDS; end

    def validate
    end

    ::Thrift::Struct.generate_accessors self
  end

  class AddPublicKey_result
    include ::Thrift::Struct, ::Thrift::Struct_Union

    FIELDS = {

    }

    def struct_fields; FIELDS; end

    def validate
    end

    ::Thrift::Struct.generate_accessors self
  end

  class DeletePublicKey_args
    include ::Thrift::Struct, ::Thrift::Struct_Union
    KEYID = 1
    USERID = 2
    PUBLICKEY = 3

    FIELDS = {
      KEYID => {:type => ::Thrift::Types::I32, :name => 'keyId'},
      USERID => {:type => ::Thrift::Types::I32, :name => 'userId'},
      PUBLICKEY => {:type => ::Thrift::Types::STRING, :name => 'publicKey'}
    }

    def struct_fields; FIELDS; end

    def validate
    end

    ::Thrift::Struct.generate_accessors self
  end

  class DeletePublicKey_result
    include ::Thrift::Struct, ::Thrift::Struct_Union

    FIELDS = {

    }

    def struct_fields; FIELDS; end

    def validate
    end

    ::Thrift::Struct.generate_accessors self
  end

  class CreateRepository_args
    include ::Thrift::Struct, ::Thrift::Struct_Union
    REPOSITORYID = 1

    FIELDS = {
      REPOSITORYID => {:type => ::Thrift::Types::I32, :name => 'repositoryId'}
    }

    def struct_fields; FIELDS; end

    def validate
    end

    ::Thrift::Struct.generate_accessors self
  end

  class CreateRepository_result
    include ::Thrift::Struct, ::Thrift::Struct_Union

    FIELDS = {

    }

    def struct_fields; FIELDS; end

    def validate
    end

    ::Thrift::Struct.generate_accessors self
  end

  class DeleteRepository_args
    include ::Thrift::Struct, ::Thrift::Struct_Union
    REPOSITORYID = 1

    FIELDS = {
      REPOSITORYID => {:type => ::Thrift::Types::I32, :name => 'repositoryId'}
    }

    def struct_fields; FIELDS; end

    def validate
    end

    ::Thrift::Struct.generate_accessors self
  end

  class DeleteRepository_result
    include ::Thrift::Struct, ::Thrift::Struct_Union

    FIELDS = {

    }

    def struct_fields; FIELDS; end

    def validate
    end

    ::Thrift::Struct.generate_accessors self
  end

end

