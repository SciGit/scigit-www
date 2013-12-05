require 'thrift'
require 'scigit/repository_manager'

module SciGit
	class ThriftClient
		def initialize
			transport = Thrift::BufferedTransport.new(Thrift::Socket.new('', 9090))
			protocol = Thrift::BinaryProtocol.new(transport)
			@client = RepositoryManager::Client.new(protocol)
			transport.open()
		end

		def createRepository(repo_id)
			@client.createRepository(repo_id)
		end

		def deleteRepository(repo_id)
			@client.deleteRepository(repo_id)
		end

		def addPublicKey(key_id, user_id, public_key)
			@client.addPublicKey(key_id, user_id, public_key)
		end

		def deletePublicKey(key_id, user_id, public_key)
			@client.deletePublicKey(key_id, user_id, public_key)
		end
	end
end
