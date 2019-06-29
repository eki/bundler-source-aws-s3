# frozen_string_literal: true

require 'fileutils'
require 'open3'
require 'rubygems/package'

class BundlerSourceAwsS3 < Bundler::Plugin::API
  class S3Source < Bundler::Source
    # Bundler plugin api, we need to install the gem for the given spec and
    # then call post_install.
    def install(spec, opts)
      print_using_message "Using #{spec.name} #{spec.version} from #{self}"

      validate!(spec)

      package = package_for(spec)
      destination = install_path.join(spec.full_name)

      Bundler.mkdir_p(destination)
      package.extract_files(destination)
      File.open(spec.loaded_from, 'wb') { |f| f.write spec.to_ruby }

      post_install(spec)
    end

    # Bundler plugin api, we need to return a Bundler::Index
    def specs
      # Only pull gems if bundler tells us to check remote
      pull if remote?

      # We haven't pulled any s3 gems if the directory doesn't exist, so we'll
      # give bundler an empty index.
      return Bundler::Index.new unless File.directory?(s3_gems_path)

      Bundler::Index.build do |index|
        packages.map(&:spec).each do |spec|
          spec.source = self
          spec.loaded_from = loaded_from_for(spec)

          Bundler.rubygems.validate(spec)
          index << spec
        end
      end
    end

    # Bundler calls this to tell us fetching remote gems is okay.
    def remote!
      @remote = true
    end

    def remote?
      @remote
    end

    # TODO What is bundler telling us if unlock! is called?
    def unlock!
      puts "[aws-s3] DEBUG: unlock! called"
    end

    # TODO What is bundler telling us if cached! is called?
    def cached!
      puts "[aws-s3] DEBUG: cached! called"
    end

    def to_s
      "aws-s3 plugin with uri #{uri}"
    end

    private

    # This is a guard against attempting to install a spec that doesn't match
    # our requirements / expectations.
    #
    # If we want to be more trusting, we could probably safely remove this
    # method.
    def validate!(spec)
      unless spec.source == self && spec.loaded_from == loaded_from_for(spec)
        raise "[aws-s3] Error #{spec.full_name} spec is not valid"
      end
    end

    # We will use this value as the given spec's loaded_from. It should be the
    # path fo the installed gem's gemspec.
    def loaded_from_for(spec)
      destination = install_path.join(spec.full_name)
      destination.join("#{spec.full_name}.gemspec").to_s
    end

    # This path is going to be under bundler's gem_install_dir and we'll then
    # mirror the bucket/path directory structure from the source. This is where
    # we want to place our gems. This directory can hold multiple installed
    # gems.
    def install_path
      @install_path ||= gem_install_dir.join(bucket).join(path)
    end

    # This is the path to the s3 gems for our source uri. We will pull the s3
    # gems into this directory.
    def s3_gems_path
      Bundler.user_bundle_path.
        join('bundler-source-aws-s3').join(bucket).join(path)
    end

    # Pull s3 gems from the source and store them in
    # .bundle/bundler-source-aws-s3/<bucket>/<path>. We will install, etc, from
    # this directory.
    def pull
      # We only want to pull once in a single bundler run.
      return @pull if defined?(@pull)

      Bundler.mkdir_p(s3_gems_path)

      output, status = Open3.capture2e(sync_cmd)

      @pull = status.success?
    end

    # Produces a list of Gem::Package for the s3 gems.
    def packages
      @packages ||= Dir.entries(s3_gems_path.join('gems')).
        map { |entry| s3_gems_path.join('gems').join(entry) }.
        select { |gem_path| File.file?(gem_path) }.
        map { |gem_path| Gem::Package.new(gem_path.to_s) }
    end

    # Find the Gem::Package for a given spec.
    def package_for(spec)
      packages.find { |package| package.spec.full_name == spec.full_name }
    end

    def sync_cmd
      "aws s3 sync --delete #{uri} #{s3_gems_path}"
    end

    def bucket
      URI.parse(uri).normalize.host
    end

    def path
      # Remove the leading slash from the path.
      URI.parse(uri).normalize.path[1..-1]
    end
  end

  source 'aws-s3', S3Source
end
