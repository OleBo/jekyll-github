require 'jekyll'

module Jekyll
  class Github
    InvalidJekyllGithubConfig = Class.new(Jekyll::Errors::FatalException)

    GH_COMMAND = 'gh@'

    REGEX_S = {
      'mention'     => /^[a-zA-Z0-9_.\-]+$/.freeze,
      'repo'        => /^[a-zA-Z0-9_.\-]+\/[a-zA-Z0-9_.\-]+$/.freeze,
      'repo_branch' => /^[a-zA-Z0-9_.\-]+\/[a-zA-Z0-9_.\-]+:[a-zA-Z0-9_.\-]+$/.freeze,
      'issue_pr'    => /^[a-zA-Z0-9_.\-]+\/[a-zA-Z0-9_.\-]+#[1-9][0-9]*$/.freeze,
      'file'        => /^[a-zA-Z0-9_.\-]+\/[a-zA-Z0-9_.\-]+\/[a-zA-Z0-9_.\-][a-zA-Z0-9_.\-\/]*$/.freeze,
      'file_branch' => /^[a-zA-Z0-9_.\-]+\/[a-zA-Z0-9_.\-]+:[a-zA-Z0-9_.\-]+\/[a-zA-Z0-9_.\-][a-zA-Z0-9_.\-\/]*$/.freeze,
      'tag'         => /^[a-zA-Z0-9_.\-]+\/[a-zA-Z0-9_.\-]+=[a-zA-Z0-9_.\-]+$/.freeze
    }.freeze

    FORMAT_VARIABLES = {
      'user'      => '<user>',
      'repo'      => '<repo>',
      'branch'    => '<branch>',
      'issue_pr'  => '<issue_pr>',
      'file'      => '<file>',
      'tag'       => '<tag>',
      'link'      => '<link>'
    }

    DEFAULT_CONFIG = {
      'mention'     => '@<user>',
      'repo'        => '<user>/<repo>',
      'repo_branch' => '<user>/<repo>:<branch>',
      'issue_pr'    => '#<issue_pr>',
      'file'        => '<repo>/<file>',
      'file_branch' => '<repo>:<branch>/<file>',
      'tag'         => '<repo>=<tag>'
    }

    def initialize(document)
      @content = document.content
      @config = DEFAULT_CONFIG
      configure(document.site.config, document.data)
    end

    def configure(site_data, doc_data)
      parse_data(site_data['jekyll-github'])
      parse_data(doc_data['jekyll-github'])
    end

    def parse_data(data)
      case data
      when nil, NilClass
        return
      when Hash
        write_config(data)
      else raise InvalidJekyllGithubConfig,
                 'Only Hash data type accepted as \'jekyll-github\' config'
      end
    end

    def write_config(data)
      data.each { |key, val| @config[key] = val if DEFAULT_CONFIG.key?(key) }
    end

    def render_content
      return @content unless @content.include?(GH_COMMAND)
      i = -1 # as it increments first
      while i < @content.length do
        i += 1
        next unless @content[i, GH_COMMAND.length] == GH_COMMAND
        s = i
        while i < @content.length do
          i += 1
          break if @content[i].match(/\s/)
        end
        e = i
        word = process_word(@content[s...e])
        @content = @content[0...s] + word + @content[e...(@content.length)]
      end
      return @content
    end

    def process_word(word)
      content = word[(GH_COMMAND.length)...(word.length)]
      REGEX_S.each { |key, val| content.match(val) { return segregate_word(key, content) } }
      return word
    end

    def segregate_word(pattern, word)
      case pattern
      when 'mention'
        return process_mention(word)
      when 'repo'
        return process_repo(word)
      when 'repo_branch'
        return process_repo_branch(word)
      when 'issue_pr'
        return process_issue_pr(word)
      when 'file'
        return process_file(word)
      when 'file_branch'
        return process_file_branch(word)
      when 'tag'
        return process_tag(word)
      end
    end

    def process_mention(word)
      text = @config['mention'].gsub(FORMAT_VARIABLES['user'], word)
      link = "https://github.com/#{word}"
      text.gsub!(FORMAT_VARIABLES['link'], link)
      return "[#{text}](#{link})"
    end

    def process_repo(word)
      items = word.split('/')
      user  = items[0]
      repo  = items[1]
      text  = @config['repo']
      text.gsub!(FORMAT_VARIABLES['user'], user)
      text.gsub!(FORMAT_VARIABLES['repo'], repo)
      link = "https://github.com/#{user}/#{repo}"
      text.gsub!(FORMAT_VARIABLES['link'], link)
      return "[#{text}](#{link})"
    end

    def process_repo_branch(word)
      items  = word.split('/')
      user   = items[0]
      items  = items[1].split(':')
      repo   = items[0]
      branch = items[1]
      text   = @config['repo_branch']
      text.gsub!(FORMAT_VARIABLES['user'], user)
      text.gsub!(FORMAT_VARIABLES['repo'], repo)
      text.gsub!(FORMAT_VARIABLES['branch'], branch)
      link = "https://github.com/#{user}/#{repo}/tree/#{branch}"
      text.gsub!(FORMAT_VARIABLES['link'], link)
      return "[#{text}](#{link})"
    end

    def process_issue_pr(word)
      items    = word.split('/')
      user     = items[0]
      items    = items[1].split('#')
      repo     = items[0]
      issue_pr = items[1]
      text     = @config['issue_pr']
      text.gsub!(FORMAT_VARIABLES['user'], user)
      text.gsub!(FORMAT_VARIABLES['repo'], repo)
      text.gsub!(FORMAT_VARIABLES['issue_pr'], issue_pr)
      link = "https://github.com/#{user}/#{repo}/pull/#{issue_pr}"
      text.gsub!(FORMAT_VARIABLES['link'], link)
      return "[#{text}](#{link})"
    end

    def process_file(word)
      items = word.split('/')
      user  = items[0]
      repo  = items[1]
      file  = items[2...(items.length)].join('/')
      text  = @config['file']
      text.gsub!(FORMAT_VARIABLES['user'], user)
      text.gsub!(FORMAT_VARIABLES['repo'], repo)
      text.gsub!(FORMAT_VARIABLES['file'], file)
      link = "https://github.com/#{user}/#{repo}/tree/master/#{file}"
      text.gsub!(FORMAT_VARIABLES['link'], link)
      return "[#{text}](#{link})"
    end

    def process_file_branch(word)
      items  = word.split(':')
      tempi  = items[0].split('/')
      user   = tempi[0]
      repo   = tempi[1]
      items  = items[1].split('/')
      branch = items[0]
      file   = items[1...(items.length)].join('/')
      text   = @config['file_branch']
      text.gsub!(FORMAT_VARIABLES['user'], user)
      text.gsub!(FORMAT_VARIABLES['repo'], repo)
      text.gsub!(FORMAT_VARIABLES['branch'], branch)
      text.gsub!(FORMAT_VARIABLES['file'], file)
      link = "https://github.com/#{user}/#{repo}/tree/#{branch}/#{file}"
      text.gsub!(FORMAT_VARIABLES['link'], link)
      return "[#{text}](#{link})"
    end

    def process_tag(word)
      items = word.split('/')
      user  = items[0]
      items = items[1].split('=')
      repo  = items[0]
      tag   = items[1]
      text  = @config['tag']
      text.gsub!(FORMAT_VARIABLES['user'], user)
      text.gsub!(FORMAT_VARIABLES['repo'], repo)
      text.gsub!(FORMAT_VARIABLES['tag'], tag)
      link = "https://github.com/#{user}/#{repo}/releases/tag/#{tag}"
      text.gsub!(FORMAT_VARIABLES['link'], link)
      return "[#{text}](#{link})"
    end
  end
end

Jekyll::Hooks.register [:pages, :documents], :pre_render do |doc|
  github_doc  = Jekyll::Github.new(doc)
  doc.content = github_doc.render_content
end
