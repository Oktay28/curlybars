describe "Using Curlybars for the application layout", type: :request do
  example "A simple layout view in Curlybars" do
    get '/'

    expect(body).to eq(<<~HTML)
      <html>
      <head>
        <title>Dummy app</title>
      </head>
      <body>
      <h1>Dashboard</h1>
      <p>Hello, World!</p>
      <p>Welcome!</p>

      </body>
      </html>
    HTML
  end

  describe "Curlybars" do
    before do
      Curlybars.configure do |config|
        config.presenters_namespace = 'curlybars_presenters'
      end
    end

    after do
      Curlybars.reset
    end

    example "A simple layout view in Curlybars with html safe logic" do
      get '/articles/1'

      expect(body).to eq(<<~HTML)
        <html>
        <head>
          <title>Dummy app</title>
        </head>
        <body>
        <p>Hi Admin</p>

        <h1>Article: The Prince</h1>

        <p>This is <strong>important</strong>!</p>

        <p>&lt;script&gt;alert(&#39;bad&#39;)&lt;/script&gt;</p>


        <p>
          author Nicolò
          <img src="http://example.com/foo.png" />
        </p>


        </body>
        </html>
      HTML
    end
  end
end
