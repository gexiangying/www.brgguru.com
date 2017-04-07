<!DOCTYPE html> 
<% local tour = _G.require("brg.tour") %>
<html> 
	<head> 
		<title>人员列表</title> 
		<%=tour.head %>
	</head> 
	<body>
		<div data-role="page">
			<%=tour.header %>
			<div data-role="content">
			<table width="100%" class="ui-responsive table-stripe" >
					<thead>
						<tr>
							<th >编号</th>
							<th >姓名</th>
						</tr>
					</thead>
					<tbody>
					<% local db = tour.load_user_list() %>
          <% for i,v in _G.ipairs(db) do %>
					<tr>
          <td><%=i %></td>
          <td><%=v %></td>
					</tr>
          <% end %>
					</tbody>
			</table>
			</div>
			<%=tour.footer %>
		</div>
	</body>
</html>

