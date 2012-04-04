module Resque
  module Plugins
    # If you want only one instance of your job
    # queued at a time, and want to be be able to run a callback when
    # another instance tries to run while the lock is in effect,
    # extend it with this module.
    #
    # For example:
    #
    #     class UpdateNetworkGraph
    #       extend Resque::Jobs::LockWithCallback
    #
    #       def self.perform(repo_id)
    #         heavy_lifting
    #       end
    #
    #       def self.job_locked(repo_id)
    #         # Some handler for when a job is locked
    #         # and another job with the same lock key
    #         # tries to execute. For example:
    #         Resque.enqueue self, repo_id
    #       end
    #
    #     end
    #
    # No other UpdateNetworkGraph jobs will be placed on the queue,
    # the QueueLock class will check Redis to see if any others are
    # queued with the same arguments before queueing. If another
    # is queued the job_locked method will be executed. Override the
    # job_locked method to handle the enqueue attempt as you need;
    # if no job_locked method is over in the class then the enqueue
    # will be aborted.
    #
    # If you want to define the key yourself you can override the
    # `lock` class method in your subclass, e.g.
    #
    # class UpdateNetworkGraph
    #   extend Resque::Plugins::Lock
    #
    #   # Run only one at a time, regardless of repo_id.
    #   def self.lock(repo_id)
    #     "network-graph"
    #   end
    #
    #   def self.perform(repo_id)
    #     heavy_lifting
    #   end
    #
    #   def self.job_locked(repo_id)
    #     # Some handler for when a job is locked
    #     # and another job with the same lock key
    #     # tries to execute. For example:
    #     Resque.enqueue self, repo_id
    #   end
    # end
    #
    # The above modification will ensure only one job of class
    # UpdateNetworkGraph is running at a time, regardless of the
    # repo_id. Normally a job is locked using a combination of its
    # class name and arguments.
    module LockWithCallback
      # Override in your job to control the lock key. It is
      # passed the same arguments as `perform`, that is, your job's
      # payload.
      def lock(*args)
        "lock:#{name}-#{args.to_s}"
      end

      def job_locked(*args)
        # override this method to handle enqueues of locked jobs as you need
      end

      def around_perform_lock_with_callback(*args)
        if Resque.redis.setnx(lock(*args), true)
          begin
            yield
          ensure
            # Always clear the lock when we're done, even if there is an
            # error.
            Resque.redis.del(lock(*args))
          end
        else
          job_locked(*args)
        end
      end
    end
  end
end

