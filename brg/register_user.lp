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
				<form action="register_user.lp" method="POST" autocomplete="off">
					<ul data-role="listview" data-insert="true">
						<li data-role="fieldcontain">
							<label for="no1">人员编号1</label>
							<input type="number" name="no1" id="no1">
						</li>
						<li data-role="fieldcontain">
							<label for="no2">人员编号2</label>
							<input type="number" name="no2" id="no2">
						</li>
						<li data-role="fieldcontain">
							<input type="submit" value="确认" data-theme="a" >
						</li>
					</ul>
				</form>
			</div>
      <% if no1 and no2 then %>
      <%
        tour.add_partner(no1,no2)
			%>
      <% end %>
      <div data-role="content">
			<table width="100%" class="ui-responsive table-stripe" >
					<thead>
						<tr>
							<th >姓名1</th>
							<th >姓名2</th>
							<th >名次</th>
							<th >vp1</th>
							<th >vp2</th>
							<th >总和</th>
						</tr>
					</thead>
					<tbody>
					<% local db = tour.load_register_list() %>
          <% for i,v in _G.ipairs(db) do %>
					<tr>
          <td><%=v.name1 %></td>
          <td><%=v.name2 %></td>
          <td><%=i %></td>
          <td><%=v.vp1 %></td>
          <td><%=v.vp2 %></td>
          <td><%=v.vp %></td>
					</tr>
          <% end %>
					</tbody>
			</table>
			</div>
			<%=tour.footer %>
		</div>
	</body>
</html>

