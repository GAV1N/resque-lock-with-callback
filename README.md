Resque Lock
===========

A [Resque][rq] plugin. Requires Resque 1.7.0.

If you want only one instance of your job queued at a time, , and want to be be able to run a callback when
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

While this job is queued or running, no other UpdateNetworkGraph
jobs with the same arguments will be placed on the queue. The
job_locked callback will be called, allowing you to handle future
UpdateNetworkGraph jobs that run while the lock is in effect, rather
than those jobs just being skipped.

If you want to define the key yourself you can override the
`lock` class method in your subclass, e.g.

    class UpdateNetworkGraph
      extend Resque::Plugins::Lock

      Run only one at a time, regardless of repo_id.
      def self.lock(repo_id)
        "network-graph"
      end

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

The above modification will ensure only one job of class
UpdateNetworkGraph is queued at a time, regardless of the
repo_id. Normally a job is locked using a combination of its
class name and arguments.

[rq]: http://github.com/defunkt/resque
