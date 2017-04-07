<!DOCTYPE html> 
<% local tour = _G.require("brg.tour") %>
<html> 
	<head> 
		<title>添加人员</title> 
		<%=tour.head %>
	</head> 
	<body>
		<div data-role="page">
			<%=tour.header %>
			 <div data-role="content">
				<form action="adduser.lp" method="POST" autocomplete="off">
					<ul data-role="listview" data-insert="true">
						<li data-role="fieldcontain">
							<label for="name">姓名</label>
							<input type="text" name="name" id="name">
						</li>
						<li data-role="fieldcontain">
							<input type="submit" value="确认" data-theme="a" >
						</li>
					</ul>
				</form>
			</div>
      <% if name then %>
      <%
        tour.add_user(name)
			%>
      <% end %>
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
			<%=tour.adminfooter %>
		</div>
	</body>
</html>

