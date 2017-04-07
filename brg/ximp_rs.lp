<!DOCTYPE html> 
<% local tour = _G.require("brg.tour") %>
<% local url = _G.require("lpp.url") %>
<html> 
	<head> 
		<title>全场结果</title> 
		<%=tour.head %>
	</head> 
	<body>
		<div data-role="page" > 
      <%=tour.header %>
			<div data-role="content">
			<% if not tour_no then %>
				<h2>比赛列表:</h2>
			<ol data-role="listview">
			<% local tour_list = tour.load_tour_list()
				for k,v in _G.pairs(tour_list) do 
			  if v.tour_type and v.tour_type == "team" then
				local linkname = "ximp_rs.lp?tour_no=" .. url.escape(k) %>
				<li> <a href="<%=linkname %>"><%=k %></a></li>
				<% end %>
				<% end %>
			</ol>
			<% elseif not round then %>
			<h2>轮次:</h2>
				<ol data-role="listview">
					<% local tour_list = tour.load_tour_list() 
				local t = tour_list[tour_no] or {} 
				for i=1,t.rounds do
				local linkname = "ximp_rs.lp?tour_no=" .. url.escape(tour_no) .. "&round=" .. i%>
				<li> <a href="<%=linkname %>">第<%=i %>轮</a></li>
				<% end %>
				<% local linkname = "pls.lp?tour_no=" .. url.escape(tour_no) %>
				<li> <a href="<%=linkname %>">所有轮</a></li>
				</ol>
			<% end %>
			</div>		
			<% if tour_no and round then %>
			<%
						local sets,index,players = tour.load_ximp(tour_no,round)
						local users = tour.load_user_list()
      			%> 
				<div data-role="content">
				<table width="100%" class="ui-responsive table-stripe" >
				<thead>
						<tr>
							<th>姓名</th>
							<th>ximp</th>
							<th>mp</th>
							<th>副数</th>
							<th>VP</th>
						</tr>
				</thead>
				<% for i,v in _G.ipairs(players) do %>
				<tr>
					<td><%=users[v.no] %></td>
					<td><%=v.ximp %></td>
					<td><%=v.mp %></td>
					<td><%=v.boards %></td>
					<td><%=v.vp %></td>
				</tr>
				<% end %>
				</table>
			</div>

			<div data-role="content">
				<table width="100%" class="ui-responsive table-stripe" >
				<thead>
						<tr>
							<th>副序</th>
							<th>南北</th>
							<th>东西</th>
							<th>定约</th>
							<th>得分</th>
							<th>ximp</th>
							<th>mp</th>
						</tr>
				</thead>
				<% for i,v in _G.ipairs(index) do 
					local rs = sets[v]
					for j,v1 in _G.ipairs(rs) do
				%>
						<tr>
							<% if j== 1 then %>
							<td><%=v %></td>
							<% else %>
							<td></td>
							<% end %>
							<td><%=users[v1.N] %>-<%=users[v1.S] %></td>
							<td><%=users[v1.E] %>-<%=users[v1.W] %></td>
							<td><%=v1.constr %></td>
							<td><%=v1.score %></td>
							<td><%=v1.NS_ximp %></td>
							<td><%=v1.NS_mp %></td>
						</tr>	
					<% end %>
					<% end %>
				</table>
			</div>
		<% end %>
			<%=tour.footer %>
		</div>
	</body>
</html>	
