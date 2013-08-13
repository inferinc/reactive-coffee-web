viz = d3.select('#viz')

width = viz.attr('width')
height = viz.attr('height')

spaceDim = 2000

color = '#2d8399'
color = 'white'
color = '#445555'
#color = '#404b4e'
color = '#ed9000'
color = 'rgba(255, 255, 0, .1)'
color = 'black'
innerRadius = 10
outerRadius = 15

rand = new Random()
rand.seed(0)

dist = (a, b) ->
  x = Math.abs(a.x - b.x)
  y = Math.abs(a.y - b.y)
  Math.sqrt(x * x + y * y)

nodes =
  for i in [0..300]
    {
      x: width  / 2 - spaceDim / 2 + rand.random() * spaceDim
      y: height / 2 - spaceDim / 2 + rand.random() * spaceDim
    }
nodes =
  (a for a,i in nodes when _.all(dist(a,b) > 4 * outerRadius for b in _(nodes).take(i)))
edges = _.flatten(
  for a,i in nodes
    _(nodes).chain()
      .drop(i + 1)
      .sortBy((b) -> dist(a, b))
      .take(1 + Math.round(Math.abs(rand.gauss(0, 3))))
      .filter((b,i) -> i == 0 or rand.random() < Math.exp(-dist(a, b) / 150))
      .map((b) -> {a,b})
      .value()
)

gnode = viz.selectAll('.node').data(nodes).enter().append('g').classed('node', true)
gnode.append('circle')
  .attr('cx', (d) -> d.x)
  .attr('cy', (d) -> d.y)
  .attr('r', outerRadius)
  .attr('stroke', color)
  .attr('stroke-width', 2)
  .attr('fill', 'none')
gnode.append('circle')
  .attr('cx', (d) -> d.x)
  .attr('cy', (d) -> d.y)
  .attr('r', innerRadius)
  .attr('fill', color)

viz.select('defs').selectAll('.node-mask').data(nodes).enter().append('circle')
  .attr('id', (d,i) -> "node-mask-#{i}")
  .classed('node-mask', true)
  .attr('cx', (d) -> d.x)
  .attr('cy', (d) -> d.y)
  .attr('r', outerRadius)
  .attr('fill', 'black')

edgeMask = viz.select('defs').selectAll('.edge-mask').data(edges).enter().append('mask')
  .attr('id', (d,i) -> "edge-mask-#{i}")
  .classed('edge-mask', true)
edgeMask.append('rect')
  .attr('fill', 'white')
  .attr('x', (d) -> Math.min(d.a.x, d.b.x))
  .attr('y', (d) -> Math.min(d.a.y, d.b.y))
  .attr('width', (d) -> Math.abs(d.b.x - d.a.x))
  .attr('height', (d) -> Math.abs(d.b.y - d.a.y))
edgeMask.append('use')
  .attr('xlink:href', (d) -> "#node-mask-#{_(nodes).indexOf(d.a)}")
edgeMask.append('use')
  .attr('xlink:href', (d) -> "#node-mask-#{_(nodes).indexOf(d.b)}")

gedge = viz.selectAll('.edge').data(edges).enter().append('line')
  .attr('x1', (d) -> d.a.x)
  .attr('y1', (d) -> d.a.y)
  .attr('x2', (d) -> d.b.x)
  .attr('y2', (d) -> d.b.y)
  .attr('stroke', color)
  .attr('stroke-width', 2)
  .attr('mask', (d,i) -> "url(#edge-mask-#{i})")
