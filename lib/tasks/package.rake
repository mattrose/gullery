require 'rake/packagetask'

PKG_NAME      = 'gullery'
PKG_VERSION   = '0.0.2'
PKG_LABEL     = "#{PKG_NAME}-#{PKG_VERSION}"

Rake::PackageTask.new(PKG_NAME, PKG_VERSION) do |p|
  p.need_tar = true
  p.need_zip = true
  p.package_files.include("pkg/gullery/**/*")
end

desc "Export project"
task :export do
  mkdir_p "pkg"
  system "svn export http://topfunky.net/svn/gullery pkg/#{PKG_LABEL}"
end

desc "Delete empty project"
task :cleanup_package do
  rm_rf "pkg/#{PKG_LABEL}"
end

desc "Export project and make a package"
task :export_package => [:export, :package, :cleanup_package]
