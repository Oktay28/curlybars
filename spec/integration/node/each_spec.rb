describe "{{#each collection}}...{{/each}}" do
  let(:global_helpers_providers) { [] }

  describe "#compile" do
    let(:post) { double("post") }
    let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

    it "uses each_template when collection is not empty" do
      allow(presenter).to receive(:allows_method?).with(:non_empty_collection).and_return(true)
      allow(presenter).to receive(:non_empty_collection) { [presenter] }

      template = Curlybars.compile(<<-HBS)
        {{#each non_empty_collection}}
          each_template
        {{/each}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        each_template
      HTML
    end

    it "doesn't use each_template when collection is empty" do
      allow(presenter).to receive(:allows_method?).with(:empty_collection).and_return(true)
      allow(presenter).to receive(:empty_collection).and_return([])

      template = Curlybars.compile(<<-HBS)
        {{#each empty_collection}}
          each_template
        {{/each}}
      HBS

      expect(eval(template)).to resemble("")
    end

    it "allows empty each_template" do
      allow(presenter).to receive(:allows_method?).with(:non_empty_collection).and_return(true)
      allow(presenter).to receive(:non_empty_collection) { [presenter] }

      template = Curlybars.compile(<<-HBS)
        {{#each non_empty_collection}}{{/each}}
      HBS

      expect(eval(template)).to resemble("")
    end

    it "uses each_template when collection is a not empty enumerable" do
      path_presenter_class = Class.new(Curlybars::Presenter) do
        presents :path
        allow_methods :path
        def path
          @path
        end
      end

      a_path_presenter = path_presenter_class.new(nil, path: 'a_path')
      another_path_presenter = path_presenter_class.new(nil, path: 'another_path')

      allow(presenter).to receive(:allows_method?).with(:non_empty_collection).and_return(true)
      allow(presenter).to receive(:non_empty_collection) { [a_path_presenter, another_path_presenter] }

      template = Curlybars.compile(<<-HBS)
        {{#each non_empty_collection}}
          {{path}}
        {{/each}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        a_path
        another_path
      HTML
    end

    it "uses each_template when collection is a not empty hash" do
      path_presenter_class = Class.new(Curlybars::Presenter) do
        presents :path
        allow_methods :path
        def path
          @path
        end
      end

      a_path_presenter = path_presenter_class.new(nil, path: 'a_path')
      another_path_presenter = path_presenter_class.new(nil, path: 'another_path')

      allow(presenter).to receive(:allows_method?).with(:non_empty_hash).and_return(true)
      allow(presenter).to receive(:non_empty_hash) do
        { first: a_path_presenter, second: another_path_presenter }
      end

      template = Curlybars.compile(<<-HBS)
        {{#each non_empty_hash}}
          {{path}}
        {{/each}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        a_path
        another_path
      HTML
    end

    it "raises an error if the context is not an array-like object" do
      allow(presenter).to receive(:allows_method?).with(:not_a_collection).and_return(true)
      allow(presenter).to receive(:not_a_collection).and_return("string")

      template = Curlybars.compile(<<-HBS)
        {{#each not_a_collection}}{{/each}}
      HBS

      expect do
        eval(template)
      end.to raise_error(Curlybars::Error::Render)
    end

    it "renders nothing if the context is nil" do
      template = Curlybars.compile(<<-HBS)
        {{#each return_nil}}
          text
        {{/each}}
      HBS

      expect(eval(template)).to resemble("")
    end

    it "gives access to `@index` variable" do
      template = Curlybars.compile(<<-HBS)
        {{#each two_elements}}
          {{@index}}
        {{/each}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        0
        1
      HTML
    end

    it "gives access to `@first` variable" do
      template = Curlybars.compile(<<-HBS)
        {{#each two_elements}}
          {{@first}}
        {{/each}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        true
        false
      HTML
    end

    it "gives access to `@last` variable" do
      template = Curlybars.compile(<<-HBS)
        {{#each two_elements}}
          {{@last}}
        {{/each}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        false
        true
      HTML
    end

    it "gives access to variables from nested {{#with}}" do
      template = Curlybars.compile(<<-HBS)
        {{#each two_elements}}
          {{#with me}}
            {{@index}}
          {{/with}}
        {{/each}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        0
        1
      HTML
    end

    it "gives access to variables from nested {{#each}}" do
      template = Curlybars.compile(<<-HBS)
        {{#each two_elements}}
          {{#each ../two_elements}}
            {{@../index}}
          {{/each}}
        {{/each}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        0
        0
        1
        1
      HTML
    end

    it "gives access to variables when collection is a not empty hash" do
      path_presenter_class = Class.new(Curlybars::Presenter) do
        presents :path
        allow_methods :path
        def path
          @path
        end
      end

      a_path_presenter = path_presenter_class.new(nil, path: 'a_path')
      another_path_presenter = path_presenter_class.new(nil, path: 'another_path')

      allow(presenter).to receive(:allows_method?).with(:non_empty_hash).and_return(true)
      allow(presenter).to receive(:non_empty_hash) do
        { first: a_path_presenter, second: another_path_presenter }
      end

      template = Curlybars.compile(<<-HBS)
        {{#each non_empty_hash}}
          {{@index}}) {{@key}}: {{path}}
        {{/each}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        0) first: a_path
        1) second: another_path
      HTML
    end

    it "raises an error if the objects inside of the context array are not presenters" do
      allow(presenter).to receive(:allows_method?).with(:not_a_presenter_collection).and_return(true)
      allow(presenter).to receive(:not_a_presenter_collection).and_return([:an_element])

      template = Curlybars.compile(<<-HBS)
        {{#each not_a_presenter_collection}}{{/each}}
      HBS

      expect do
        eval(template)
      end.to raise_error(Curlybars::Error::Render)
    end
  end

  describe "#validate" do
    let(:presenter_class) { double(:presenter_class) }

    it "without errors" do
      dependency_tree = { a_presenter_collection: [{}] }

      source = <<-HBS
        {{#each a_presenter_collection}}{{/each}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).to be_empty
    end

    it "with errors due to a presenter path" do
      dependency_tree = { a_presenter: {} }

      source = <<-HBS
        {{#each a_presenter}}{{/each}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end

    it "with errors due to a leaf path" do
      dependency_tree = { a_leaf: nil }

      source = <<-HBS
        {{#each a_leaf}}{{/each}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end

    it "with errors due unallowed method" do
      dependency_tree = {}

      source = <<-HBS
        {{#each unallowed}}{{/each}}
      HBS

      errors = Curlybars.validate(dependency_tree, source)

      expect(errors).not_to be_empty
    end
  end
end
