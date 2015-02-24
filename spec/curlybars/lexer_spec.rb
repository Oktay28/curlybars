describe Curlybars::Lexer do
  describe "{{!-- ... --}}" do
    it "skips begin of block comment" do
      expect(lex('{{!--')).to produce []
    end

    it "skips begin and end of block comment" do
      expect(lex('{{!----}}')).to produce []
    end

    it "skips a comment block containing curlybar code" do
      expect(lex('{{!--{{helper}}--}}')).to produce []
    end

    it "is resilient to whitespaces" do
      expect(lex('{{!-- --}}')).to produce []
    end

    it "is resilient to newlines" do
      expect(lex("{{!--\n--}}")).to produce []
    end

    it "is skipped when present in plain text" do
      expect(lex('text {{!----}} text')).to produce [:TEXT, :TEXT]
    end
  end

  describe "{{! ... }}" do
    it "skips begin of block comment" do
      expect(lex('{{!')).to produce []
    end

    it "skips begin and end of block comment" do
      expect(lex('{{!}}')).to produce []
    end

    it "is resilient to whitespaces" do
      expect(lex('{{! }}')).to produce []
    end
    it "is resilient to newlines" do
      expect(lex("{{!\n}}")).to produce []
    end

    it "is lexed when present in plain text" do
      expect(lex('text {{!}} text')).to produce [:TEXT, :TEXT]
    end
  end

  describe "{{<integer>}}" do
    it "is lexed as an integer" do
      expect(lex("{{7}}")).to produce [:START, :INTEGER, :END]
    end

    it "returns the expressed boolean" do
      integer_token = lex("{{7}}").detect {|token| token.type == :INTEGER}
      expect(integer_token.value).to eq 7
    end
  end

  describe "{{<boolean>}}" do
    it "{{true}} is lexed as boolean" do
      expect(lex("{{true}}")).to produce [:START, :BOOLEAN, :END]
    end

    it "{{false}} is lexed as boolean" do
      expect(lex("{{false}}")).to produce [:START, :BOOLEAN, :END]
    end

    it "returns the expressed boolean" do
      boolean_token = lex("{{true}}").detect {|token| token.type == :BOOLEAN}
      expect(boolean_token.value).to be_truthy
    end
  end

  describe "{{''}}" do
    it "is lexed as a string" do
      expect(lex("{{''}}")).to produce [:START, :STRING, :END]
    end

    it "returns the string between quotes" do
      string_token = lex("{{'string'}}").detect {|token| token.type == :STRING}
      expect(string_token.value).to eq 'string'
    end

    it "is lexed when string is multiline" do
      expect(lex("text {{'\n'}} text")).to produce [:TEXT, :START, :STRING, :END, :TEXT]
    end

    it "is resilient to whitespaces" do
      expect(lex("{{ '' }}")).to produce [:START, :STRING, :END]
    end

    it "is lexed when present in plain text" do
      expect(lex("text {{''}} text")).to produce [:TEXT, :START, :STRING, :END, :TEXT]
    end
  end

  describe '{{""}}' do
    it "is lexed as a string" do
      expect(lex('{{""}}')).to produce [:START, :STRING, :END]
    end

    it "returns the string between quotes" do
      string_token = lex('{{"string"}}').detect {|token| token.type == :STRING}
      expect(string_token.value).to eq 'string'
    end

    it "is lexed when string is multiline" do
      expect(lex('text {{"\n"}} text')).to produce [:TEXT, :START, :STRING, :END, :TEXT]
    end

    it "is resilient to whitespaces" do
      expect(lex('{{ "" }}')).to produce [:START, :STRING, :END]
    end

    it "is lexed when present in plain text" do
      expect(lex('text {{""}} text')).to produce [:TEXT, :START, :STRING, :END, :TEXT]
    end
  end

  describe "{{path context options}}" do
    it "is lexed with context and options" do
      expect(lex('{{path context key=value}}')).to produce [:START, :PATH, :PATH, :KEY, :PATH, :END]
    end

    it "is lexed without context" do
      expect(lex('{{path key=value}}')).to produce [:START, :PATH, :KEY, :PATH, :END]
    end

    it "is lexed without options" do
      expect(lex('{{path context}}')).to produce [:START, :PATH, :PATH, :END]
    end

    it "is lexed without context and options" do
      expect(lex('{{path}}')).to produce [:START, :PATH, :END]
    end

    it "is resilient to whitespaces" do
      expect(lex('{{ path }}')).to produce [:START, :PATH, :END]
    end

    it "is lexed when present in plain text" do
      expect(lex('text {{ path }} text')).to produce [:TEXT, :START, :PATH, :END, :TEXT]
    end
  end

  describe "{{#if path}}...{{/if}}" do
    it "is lexed" do
      expect(lex('{{#if path}} text {{/if}}')).to produce(
        [:START, :HASH, :IF, :PATH, :END, :TEXT, :START, :SLASH, :IF, :END])
    end

    it "is resilient to whitespaces" do
      expect(lex('{{ # if path }} text {{/ if }}')).to produce(
        [:START, :HASH, :IF, :PATH, :END, :TEXT, :START, :SLASH, :IF, :END])
    end

    it "is lexed when present in plain text" do
      expect(lex('text {{#if path}} text {{/if}} text')).to produce(
        [:TEXT, :START, :HASH, :IF, :PATH, :END, :TEXT, :START, :SLASH, :IF, :END, :TEXT])
    end
  end

  describe "{{#if path}}...{{else}}...{{/if}}" do
    it "is lexed" do
      expect(lex('{{#if path}} text {{else}} text {{/if}}')).to produce(
        [:START, :HASH, :IF, :PATH, :END,
          :TEXT, :START, :ELSE, :END,
          :TEXT, :START, :SLASH, :IF, :END])
    end

    it "is resilient to whitespaces" do
      expect(lex('{{ # if path }} text {{ else }} text {{/ if }}')).to produce(
        [:START, :HASH, :IF, :PATH, :END,
          :TEXT, :START, :ELSE, :END,
          :TEXT, :START, :SLASH, :IF, :END])
    end

    it "is lexed when present in plain text" do
      expect(lex('text {{#if path}} text {{else}} text {{/if}} text')).to produce(
        [:TEXT, :START, :HASH, :IF, :PATH, :END,
          :TEXT, :START, :ELSE, :END,
          :TEXT, :START, :SLASH, :IF, :END, :TEXT])
    end
  end

  describe "{{#unless path}}...{{/unless}}" do
    it "is lexed" do
      expect(lex('{{#unless path}} text {{/unless}}')).to produce(
        [:START, :HASH, :UNLESS, :PATH, :END, :TEXT, :START, :SLASH, :UNLESS, :END])
    end

    it "is resilient to whitespaces" do
      expect(lex('{{ # unless path }} text {{/ unless }}')).to produce(
        [:START, :HASH, :UNLESS, :PATH, :END, :TEXT, :START, :SLASH, :UNLESS, :END])
    end

    it "is lexed when present in plain text" do
      expect(lex('text {{#unless path}} text {{/unless}} text')).to produce(
        [:TEXT, :START, :HASH, :UNLESS, :PATH, :END, :TEXT, :START, :SLASH, :UNLESS, :END, :TEXT])
    end
  end

  describe "{{#unless path}}...{{else}}...{{/unless}}" do
    it "is lexed" do
      expect(lex('{{#unless path}} text {{else}} text {{/unless}}')).to produce(
        [:START, :HASH, :UNLESS, :PATH, :END,
          :TEXT, :START, :ELSE, :END,
          :TEXT, :START, :SLASH, :UNLESS, :END])
    end

    it "is resilient to whitespaces" do
      expect(lex('{{ # unless path }} text {{ else }} text {{/ unless }}')).to produce(
        [:START, :HASH, :UNLESS, :PATH, :END,
          :TEXT, :START, :ELSE, :END,
          :TEXT, :START, :SLASH, :UNLESS, :END])
    end

    it "is lexed when present in plain text" do
      expect(lex('text {{#unless path}} text {{else}} text {{/unless}} text')).to produce(
        [:TEXT, :START, :HASH, :UNLESS, :PATH, :END,
          :TEXT, :START, :ELSE, :END,
          :TEXT, :START, :SLASH, :UNLESS, :END, :TEXT])
    end
  end

  describe "{{#each path}}...{{/each}}" do
    it "is lexed" do
      expect(lex('{{#each path}} text {{/each}}')).to produce(
        [:START, :HASH, :EACH, :PATH, :END, :TEXT, :START, :SLASH, :EACH, :END])
    end

    it "is resilient to whitespaces" do
      expect(lex('{{ # each path }} text {{/ each }}')).to produce(
        [:START, :HASH, :EACH, :PATH, :END, :TEXT, :START, :SLASH, :EACH, :END])
    end

    it "is lexed when present in plain text" do
      expect(lex('text {{#each path}} text {{/each}} text')).to produce(
        [:TEXT, :START, :HASH, :EACH, :PATH, :END, :TEXT, :START, :SLASH, :EACH, :END, :TEXT])
    end
  end

  describe "{{#each path}}...{{else}}...{{/each}}" do
    it "is lexed" do
      expect(lex('{{#each path}} text {{else}} text {{/each}}')).to produce(
        [:START, :HASH, :EACH, :PATH, :END,
          :TEXT, :START, :ELSE, :END,
          :TEXT, :START, :SLASH, :EACH, :END])
    end

    it "is resilient to whitespaces" do
      expect(lex('{{ # each path }} text {{ else }} text {{/ each }}')).to produce(
        [:START, :HASH, :EACH, :PATH, :END,
          :TEXT, :START, :ELSE, :END,
          :TEXT, :START, :SLASH, :EACH, :END])
    end

    it "is lexed when present in plain text" do
      expect(lex('text {{#each path}} text {{else}} text {{/each}} text')).to produce(
        [:TEXT, :START, :HASH, :EACH, :PATH, :END,
          :TEXT, :START, :ELSE, :END,
          :TEXT, :START, :SLASH, :EACH, :END, :TEXT])
    end
  end

  describe "{{#with path}}...{{/with}}" do
    it "is lexed" do
      expect(lex('{{#with path}} text {{/with}}')).to produce(
        [:START, :HASH, :WITH, :PATH, :END, :TEXT, :START, :SLASH, :WITH, :END])
    end

    it "is resilient to whitespaces" do
      expect(lex('{{ # with path }} text {{/ with }}')).to produce(
        [:START, :HASH, :WITH, :PATH, :END, :TEXT, :START, :SLASH, :WITH, :END])
    end

    it "is lexed when present in plain text" do
      expect(lex('text {{#with path}} text {{/with}} text')).to produce(
        [:TEXT, :START, :HASH, :WITH, :PATH, :END, :TEXT, :START, :SLASH, :WITH, :END, :TEXT])
    end
  end

  describe "{{#path path options}}...{{/path}}" do
    it "is lexed with context and options" do
      expect(lex('{{#path context key=value}} text {{/path}}')).to produce(
        [:START, :HASH, :PATH, :PATH, :KEY, :PATH, :END, :TEXT, :START, :SLASH, :PATH, :END])
    end

    it "is lexed without options" do
      expect(lex('{{#path context}} text {{/path}}')).to produce(
        [:START, :HASH, :PATH, :PATH, :END, :TEXT, :START, :SLASH, :PATH, :END])
    end

    it "is resilient to whitespaces" do
      expect(lex('{{ # path context key = value}} text {{/ path }}')).to produce(
        [:START, :HASH, :PATH, :PATH, :KEY, :PATH, :END, :TEXT, :START, :SLASH, :PATH, :END])
    end

    it "is lexed when present in plain text" do
      expect(lex('text {{#path context key=value}} text {{/path}} text')).to produce(
        [:TEXT, :START, :HASH, :PATH, :PATH, :KEY, :PATH, :END, :TEXT, :START, :SLASH, :PATH, :END, :TEXT])
    end
  end

  describe "{{>path}}" do
    it "is lexed" do
      expect(lex('{{>path}}')).to produce [:START, :GT, :PATH, :END]
    end

    it "is resilient to whitespaces" do
      expect(lex('{{ > path }}')).to produce [:START, :GT, :PATH, :END]
    end

    it "is lexed when present in plain text" do
      expect(lex('text {{>path}} text')).to produce [:TEXT, :START, :GT, :PATH, :END, :TEXT]
    end
  end

  describe "when a leading backslash is present" do
    it "`{` is lexed as plain text" do
      expect(lex('\{')).to produce [:TEXT]
    end

    it "returns the original text" do
      text_token = lex('\{').detect {|token| token.type == :TEXT}
      expect(text_token.value).to eq '{'
    end

    it "is lexed when present in plain text" do
      expect(lex('text \{ text')).to produce [:TEXT, :TEXT, :TEXT]
    end
  end

  describe "outside a curlybar context" do
    it "`--}}` is lexed as plain text" do
      expect(lex('--}}')).to produce [:TEXT]
    end

    it "`}}` is lexed as plain text" do
      expect(lex('}}')).to produce [:TEXT]
    end

    it "`#` is lexed as plain text" do
      expect(lex('#')).to produce [:TEXT]
    end

    it "`/` is lexed as plain text" do
      expect(lex('/')).to produce [:TEXT]
    end

    it "`>` is lexed as plain text" do
      expect(lex('>')).to produce [:TEXT]
    end

    it "`if` is lexed as plain text" do
      expect(lex('if')).to produce [:TEXT]
    end

    it "`unless` is lexed as plain text" do
      expect(lex('unless')).to produce [:TEXT]
    end

    it "`each` is lexed as plain text" do
      expect(lex('each')).to produce [:TEXT]
    end

    it "`with` is lexed as plain text" do
      expect(lex('with')).to produce [:TEXT]
    end

    it "`else` is lexed as plain text" do
      expect(lex('else')).to produce [:TEXT]
    end

    it "a path is lexed as plain text" do
      expect(lex('this.is.a.path')).to produce [:TEXT]
    end

    it "an option is lexed as plain text" do
      expect(lex('key=value')).to produce [:TEXT]
    end
  end
end
