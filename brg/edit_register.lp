<!DOCTYPE html> 
<% local tour = _G.require("brg.tour") %>
<html> 
	<head> 
		<title>比赛报名</title> 
		<%=tour.head %>
	</head> 
	<body>
		<div data-role="page">
			<%=tour.header %>
			<div data-role="content">
			<table width="100%" class="ui-responsive table-stripe" >
					<thead>
						<tr>
							<th >序号</th>
							<th >编号</th>
							<th >姓名</th>
							<th >编号</th>
							<th >姓名</th>
						</tr>
					</thead>
					<tbody>
						<% if del then %>
						<% tour.del_partner(del) %>
						<% end %>
					<% local db = tour.load_user_list() %>
					<% local partners = tour.load_partner() %>	
          <% for i,v in _G.ipairs(partners) do %>
					<tr>
						<td><a href="edit_register.lp?del=<%=i %>"><%=i %></a></td>
          <td><%=v.no1 %></td>
          <td><%=db[v.no1] %></td>
          <td><%=v.no2 %></td>
          <td><%=db[v.no2] %></td>
					</tr>
          <% end %>
					</tbody>
			</table>
			</div>
			<%=tour.adminfooter %>
		</div>
	</body>
</html>

