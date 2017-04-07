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
			<% if tour_no then %>
			<%
						local players = tour.get_tour_pls(tour_no)
						local users = tour.load_user_list()
      			%> 
				<div data-role="content">
				<table width="100%" class="ui-responsive table-stripe" >
				<thead>
						<tr>
							<th>名次</th>
							<th>姓名</th>
							<th>vp</th>
							<th>每轮vp</th>
						</tr>
				</thead>
				<% for i,v in _G.ipairs(players) do %>
				<tr>
					<td>第<%=i %>名</td>
					<td><%=users[v.no] %></td>
					<td><%=v.vp %></td>
					<% local str="" 
							for k,vp in _G.ipairs(v.rs) do
												str = str .. vp .. "--" 
							end %>
          <td><%=str %></td>
				</tr>
				<% end %>
				</table>
				<% end %>
			</div>

		<%=tour.footer %>
		</div>
	</body>
</html>	
