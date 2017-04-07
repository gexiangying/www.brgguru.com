<!DOCTYPE html> 
<% local tour = _G.require("brg.tour") %>
<% local url = _G.require("lpp.url") %>
<html> 
	<head> 
		<title>比赛对阵表</title> 
		<%=tour.head %>
	</head> 
	<body>
		<% if not tour_no then %>
		<div data-role="page">
			 <div data-role="content">
				 <h2>比赛列表:</h2>
				<ol data-role="listview">
					<% local tour_list = tour.load_tour_list() 
				     for k,v in _G.pairs(tour_list) do 
				if v.tour_type and v.tour_type == "txs" then
				local linkname = "round.lp?tour_no=" .. url.escape(k) %>
				<li> <a href="<%=linkname %>"><%=k %></a></li>
				<% end %>
					<% end %>
				</ol>

				</div>
			<%=tour.footer %>
		</div>

		<% else %>
		<%
		 local db = tour.load_admin(tour_no) or {}
		 local round = db.round or {} 
	  %>
		<div data-role="page">
			<div data-role="content">
			<ul data-role="listview" data-inset="true" data-divider-theme="a">
				<% for i,v in _G.ipairs(round) do %>
				<li data-role="list-divider">第<%=i %>轮</li>
				  <% for j,m in _G.ipairs(v) do %>
					<li>第<%=j %>桌 南北:<%=m.NS %> 东西:<%=m.EW %> 副序(<%=m.l %>---<%=m.h %>)</li>
			    <% end %>
			  <% end %>
			</ul>
			</div>
			<%=tour.footer %>
		</div>
  <% end %>
	</body>
</html>

