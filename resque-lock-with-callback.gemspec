Gem::Specification.new do |s|
  s.name              = "resque-lock-with-callback"
  s.version           = "1.0.0"
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "A fork of the resque-lock plugin that will execute a callback if a job is skipped due to a lock."
  s.homepage          = "http://github.com/GAV1N/resque-lock-with-callback"
  s.email             = "gavin.todes@gmail.com"
  s.authors           = [ "Gavin Todes", "Chris Wanstrath", "Ray Krueger" ]
  s.has_rdoc          = false

  s.files             = %w( README.md Rakefile LICENSE )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("test/**/*")

  s.description       = <<desc
A Resque plugin. If you want only one instance of your job
queued at a time, and want to be be able to run a callback when
another instance tries to run while the lock is in effect,
extend it with this module.

For example:

    class UpdateNetworkGraph
      extend Resque::Jobs::LockWithCallback

      def self.perform(repo_id)
        heavy_lifting
      end

      def self.job_locked(repo_id)
        # Some handler for when a job is locked
        # and another job with the same lock key
        # tries to execute. For example:
        Resque.enqueue self, repo_id
      end

    end
desc
end
