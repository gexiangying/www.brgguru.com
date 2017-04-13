<!DOCTYPE html> 
<% local tour = _G.require("brg.tour") %>
<% local url = _G.require("lpp.url") %>
<html> 
	<head> 
		<title>总成绩列表</title> 
		<%=tour.head %>
	</head> 
	<body>
		<div data-role="page">
			<%=tour.header %>
			<% if tour_no then %>
			<%
					local pls,rounds = tour.load_total(tour_no)																					 
			 %>
      <div data-role="content">
			<table width="100%" data-role="table" class="ui-responsive table-stripe" >
					<thead>
						<tr>
							<th>名称</th>
							<th>名次</th>
							<th>总成绩</th>
							<% for i=1,rounds do %>
							<th >第<%=i %>轮</th>
							<% end %>
							<th>调整</th>
						</tr>
					</thead>
					<tbody>
          <% for i,v in _G.ipairs(pls) do %>
					<tr>
          <td><%=v.name %></td>
          <td>第<%=i %>名</td>
					<td><%=v.total %></td>
					<% for round=1,rounds do %>
					<td><%=v.vp[round] or 0 %></td>
					<% end %>
					<td><%=v.vp[rounds+1] or 0 %></td>
					</tr>
          <% end %>
					</tbody>
			</table>
			</div>
			<% end %>
			<%=tour.footer %>
		</div>
	</body>
</html>

