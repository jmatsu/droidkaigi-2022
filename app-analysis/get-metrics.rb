#!/usr/bin/env ruby

require 'json'
require 'rexml/document'
require 'shellwords'
require 'tempfile'

# Usage
#
# export BUNDLETOOL_JAR_PATH=/path/to/bundletool.jar
# ./get-metrics <bundle.aab>

class Bundletool
    # @param jar_path [String] bundletool.jar のパス
    def initialize(jar_path:, bundle_path:)
        @jar_path = jar_path
        @bundle_path = bundle_path
    end

    def android_manifest_xml
        execute("dump", "manifest", "--bundle", @bundle_path)
    end

    def universal_apk
        get_size(mode: 'universal')
    end

    def persistent_apk
        get_size(mode: 'persistent')
    end
  
    # @return [String] コマンド実行結果
    private def execute(*args)
        `java -jar #{@jar_path.shellescape} #{args.shelljoin}`.chomp
    end

    # @return [Hash] { MIN => <size>, MAX => <size> }
    private def get_size(mode:)
        content = Tempfile.open([mode, ".apks"]) do |f|
            execute("build-apks", "--mode", mode, "--output", f.path, "--overwrite", "--bundle", @bundle_path)
            execute("get-size", "total", "--apks", f.path)
        end

        content.split(/\r\n/).map { |l| l.split(",") }.transpose.to_h
    end
end

class AndroidManifet
    def initialize(content:)
        @content = content
        @document = REXML::Document.new(@content)
    end

    def package_name
        @document.elements['/manifest/@package']
    end

    def target_sdk_version
        @document.elements['/manifest/uses-sdk/@android:targetSdkVersion']
    end

    def min_sdk_version
        @document.elements['/manifest/uses-sdk/@android:minSdkVersion']
    end

    def version_code
        @document.elements['/manifest/@android:versionCode']
    end

    def version_name
        @document.elements['/manifest/@android:versionName']
    end

    def use_permissions
        return @use_permissions if defined?(@use_permissions)

        @use_permissions = []

        @document.elements.each('/manifest/uses-permission/') do |permission|
            @use_permissions << permission.attributes.transform_values { |attr| attr.value }
        end

        @use_permissions
    end

    def required_features
        features.filter { |f| f["required"].to_s == "true" }
    end

    def to_h
        [
            :package_name,
            :target_sdk_version,
            :min_sdk_version,
            :version_code,
            :version_name,
            :use_permissions,
            :required_features
        ].map { |attr|
           [attr, send(attr)]
        }.to_h
    end

    private def features
        return @features if defined?(@features)

        @features = []

        @document.elements.each('/manifest/uses-feature/') do |feature|
            @features << feature.attributes.transform_values { |attr| attr.value }
        end

        @features
    end
end

bundletool_jar_path = ENV['BUNDLETOOL_JAR_PATH']

raise "#{bundletool_jar_path} is not found" unless File.exist?(bundletool_jar_path)

bundle_path = ARGV[0]

raise "#{bundle_path} is not found" unless File.exist?(bundle_path)

bundletool = Bundletool.new(jar_path: bundletool_jar_path, bundle_path: bundle_path)

results = {}

results[:manifest] = AndroidManifet.new(content: bundletool.android_manifest_xml).to_h
results[:persistent] = bundletool.persistent_apk
results[:universal] = bundletool.universal_apk

puts JSON.pretty_generate(results)
