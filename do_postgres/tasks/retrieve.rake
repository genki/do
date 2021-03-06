begin
  gem('rake-compiler')
  require 'rake/clean'
  require 'rake/extensioncompiler'

  # download postgres library and headers
  directory "vendor"

  # only on Windows or cross platform compilation
  def dlltool(dllname, deffile, libfile)
    # define if we are using GCC or not
    if Rake::ExtensionCompiler.mingw_gcc_executable then
      dir = File.dirname(Rake::ExtensionCompiler.mingw_gcc_executable)
      tool = case RUBY_PLATFORM
        when /mingw/
          File.join(dir, 'dlltool.exe')
        when /linux|darwin/
          File.join(dir, "#{Rake::ExtensionCompiler.mingw_host}-dlltool")
      end
      return "#{tool} --dllname #{dllname} --def #{deffile} --output-lib #{libfile}"
    else
      if RUBY_PLATFORM =~ /mswin/ then
        tool = 'lib.exe'
      else
        fail "Unsupported platform for cross-compilation (please, contribute some patches)."
      end
      return "#{tool} /DEF:#{deffile} /OUT:#{libfile}"
    end
  end

  def copy(from, to)
    if WINDOWS
      from.gsub!(/\//, '\\')
      to.gsub!(/\//, '\\')
    end
    sh "#{WINDOWS ? 'copy' : 'cp'} #{from} #{to}"
  end

  version = '8.3.7'
  file "vendor/postgresql-#{version}-1-binaries-no-installer.zip" => ['vendor'] do |t|
    url = "http://wwwmaster.postgresql.org/redir/107/h/binary/v#{version}/win32/#{File.basename(t.name)}"
    when_writing "downloading #{t.name}" do
      cd File.dirname(t.name) do
        sh "wget -c #{url} || curl -C - -O #{url}"
      end
      touch t.name
    end
  end

  file "vendor/pgsql/include/pg_config.h" => ["vendor/postgresql-#{version}-1-binaries-no-installer.zip"] do |t|
    full_file = File.expand_path(t.prerequisites.last)
    when_writing "creating #{t.name}" do
      cd "vendor" do
        sh "unzip #{full_file} pgsql/bin/** pgsql/include/** pgsql/lib/**"
      end
      copy "ext/do_postgres_ext/pg_config.h", "vendor/pgsql/include/pg_config.h"
      copy "ext/do_postgres_ext/pg_config.h", "vendor/pgsql/include/server/pg_config.h"

      # update file timestamp to avoid Rake perform this extraction again.
      touch t.name
    end
  end

  # clobber vendored packages
  CLOBBER.include('vendor')

  # vendor:postgres
  task 'vendor:postgres' => ["vendor/pgsql/include/pg_config.h"]

  # hook into cross compilation vendored postgres dependency
  if RUBY_PLATFORM =~ /mingw|mswin/ then
    Rake::Task['compile'].prerequisites.unshift 'vendor:postgres'
  else
    if Rake::Task.tasks.map {|t| t.name }.include? 'cross'
      Rake::Task['cross'].prerequisites.unshift 'vendor:postgres'
    end
  end
rescue LoadError
end
