class Riemann::Dash
  PARAMS = [
    'target',
    'height',
    'width',
    'areaMode',
    'from',
    'until',
    'title',
    'template'
  ]

  D = lambda do |x|
   "scale(summarize(derivative(#{x}), \"1h\"), 24)"
  end

  S = lambda do |x|
    "movingAverage(#{x}, 10)"
  end

  TYPES = {
    'data' =>
      [
        {'title' => 'Memory', 'target' => '*data*.memory'},
        {'title' => 'CPU', 'target' => S['*data*.cpu']},
        {'title' => 'Load', 'target' => '*data*.load'}
      ],
    'coll' =>
      [
        {'title' => 'Memory', 'target' => '*coll*.memory'},
        {'title' => 'CPU', 'target' => S['*coll*.cpu']},
        {'title' => 'Load', 'target' => '*coll*.load'}
      ],
    'strm' =>
      [
        {'title' => 'Memory', 'target' => '*strm*.memory'},
        {'title' => 'CPU', 'target' => S['*strm*.cpu']},
        {'title' => 'Load', 'target' => '*strm*.load'}
      ],
    'mess' =>
      [
        {'title' => 'Memory', 'target' => '*mess*.memory'},
        {'title' => 'CPU', 'target' => S['*mess*.cpu']},
        {'title' => 'Load', 'target' => '*mess*.load'}
      ],
    'int' =>
      [
        {'title' => 'Memory', 'target' => '*int*.memory'},
        {'title' => 'CPU', 'target' => S['*int*.cpu']},
        {'title' => 'Load', 'target' => '*int*.load'}
      ],
    'kobayashi-riak' =>
      [
        {'title' => 'Gets', 'target' => '*.kobayashi.riak.node_gets', 'areaMode' => 'stacked'},
        {'title' => 'Puts', 'target' => '*.kobayashi.riak.node_puts', 'areaMode' => 'stacked'},
        {'title' => 'Get Latency', 'target' => 'kobayashi.riak.get.*'},
        {'title' => 'Put Latency', 'target' => 'kobayashi.riak.put.*'},
        {'title' => 'Disk', 'target' => 'kobayashi.riak.disk'},
        {'title' => 'Repairs', 'target' => S['kobayshi.riak.read_repairs']}
      ],
    'misc-riak' =>
      [
        {'title' => 'Gets', 'target' => '*.misc.riak.node_gets', 'areaMode' => 'stacked'},
        {'title' => 'Puts', 'target' => '*.misc.riak.node_puts', 'areaMode' => 'stacked'},
        {'title' => 'Get Latency', 'target' => 'misc.riak.get.*'},
        {'title' => 'Put Latency', 'target' => 'misc.riak.put.*'},
        {'title' => 'Disk', 'target' => 'misc.riak.disk'},
        {'title' => 'Repairs', 'target' => S['misc.riak.read_repairs']}
      ]
  }

  def graphite(h = {})
    "http://graphite.iad1.boundary.com/render" + '?' + graph_opts(h)
  end

  def graph_opts(h = {})
    o = {
      'hideLegend' => 'false',
      'template' => 'plain',
      'width' => '500',
      'height' => '300'
    }.merge Hash[h.select { |k, v|
      PARAMS.include? k.to_s
    }]
    
    o.inject([]) { |unpacked, pair|
      case pair[1]
      when Array
        unpacked + pair[1].map { |e| [pair[0], e] }
      else
        unpacked << pair
      end
    }.map { |k, v|  
      "#{Rack::Utils.escape(k)}=#{Rack::Utils.escape(v)}"
    }.join('&')
  end

  get '/graph' do
    redirect graphite request.params
  end

  get '/graphs' do
    redirect '/graphs/coll'
  end

  get '/graphs/*' do |type|
    @types = %w(coll strm data mess int) | TYPES.keys.sort
    @type = @title = type
    @graphs = case type
              when 'all'
                TYPES.values.inject(&:|)
              else
                TYPES[type] or error 404
              end
              
    @graphs = @graphs.map do |g|
      g.merge request.params
    end

    erb :graphs, :layout => :plain
  end
end
