<!DOCTYPE html> 
<% local tour = _G.require("brg.tour") %>
<html> 
	<head> 
		<title>精英群排行榜</title> 
		<%=tour.head %>
		<% days = days or 30 %>
	</head> 
	<body>
		<div data-role="page">
			<div data-role="content">
				<form action="rank.lp?days=<%=days %>" method="POST" autocomplete="off">
					<ul data-role="listview" data-insert="true">
						<li data-role="fieldcontain">
							<label for="condition">排序条件:</label>
								<select name="condition" id="condition" >
									<% if condition == "imps" then %>
									<option value="imps" selected>总和</option>
									<% else %>
									<option value="imps">总和</option>
									<% end %>
									<% if condition == "plus" then %>
									<option value="plus" selected>正分</option>
									<% else %>
									<option value="plus">正分</option>
									<% end %>
									<% if condition == "minus" then %>
									<option value="minus" selected>负分</option>
									<% else %>
									<option value="minus">负分</option>
									<% end %>
									<% if condition == "tours" then %>
									<option value="tours" selected>场次</option>
									<% else %>
									<option value="tours">场次</option>
									<% end %>
									<% if condition == "vp" then %>
									<option value="vp" selected>vp</option>
									<% else %>
									<option value="vp">vp</option>
									<% end %>

								</select>
						</li>

						<li data-role="fieldcontain">
							<input type="submit" value="确认" data-theme="a" >
						</li>
					</ul>
				</form>
			</div>
			<% if condition then %>
			<div data-role="content">
			<% local db = tour.load_master() %>
			<div data-role="content">
				<table width="100%" class="ui-responsive table-stripe" >
					<thead>
						<tr>
							<th >名次</th>
							<th >姓名</th>
							<% if condition == "tours" then %>
							<th >胜场</th>
							<th >平场</th>
							<th >负场</th>
							<%elseif condition == "vp" then %>
							<th >平均vp</th>
							<th >vp</th>
					    <% else %>
							<th >+imps</th>
							<th >-imps</th>
							<th >imps</th>
							<% end %>
							<th >场次</th>
						</tr>
					</thead>
					<tbody>
						<% local ranks={} %>
						<% for k,v in _G.pairs(db) do %>
						<%
						local year,month,day = _G.string.match(k,"(%d+)-(%d+)-(%d+)")
						local t1 = _G.os.time({year = year,month = month,day = day,hour = 9,sec = 1})
						local cur = _G.os.time()
						if cur - t1 <= days*24*60*60 then
												%>
						<% for k1,v1 in _G.pairs(v) do %>
						<% for k2,v2 in _G.pairs(v1) do %>
						<%
							ranks[k2] = ranks[k2] or {}
              ranks[k2].tours = ranks[k2].tours or 0
							ranks[k2].tours = ranks[k2].tours + 1
              ranks[k2].tour1 = ranks[k2].tour1 or 0
              ranks[k2].tour2 = ranks[k2].tour2 or 0
              ranks[k2].tour3 = ranks[k2].tour3 or 0
							ranks[k2].imps = ranks[k2].imps or 0 
							ranks[k2].imps = ranks[k2].imps + v2 
						  ranks[k2].vp = ranks[k2].vp or 0.0						
							ranks[k2].plus = ranks[k2].plus or 0
							ranks[k2].minus = ranks[k2].minus or 0
							if v2 >0 then
								ranks[k2].plus = ranks[k2].plus + v2
								ranks[k2].tour1 = ranks[k2].tour1 + 1
							elseif v2 < 0 then
								ranks[k2].minus = ranks[k2].minus + v2
								ranks[k2].tour3 = ranks[k2].tour3 + 1
              else
								ranks[k2].tour2 = ranks[k2].tour2 + 1
							end
              ranks[k2].vp = ranks[k2].vp + tour.vp(8,v2)
						%>	
						<% end %>
						<% end %>
						<% end %>
						<% end %>
						<%
						local keys = {}
						 for k,v in _G.pairs(ranks) do
						  v.name = k
						  keys[#keys+1] = v
						end
						local func = nil
						if condition == "imps" then
						  func = function(a,b) 
							return b.imps / b.tours < a.imps / a.tours
						  end	
            elseif condition == "plus" then
						  func = function(a,b) 
							return b.plus / b.tours < a.plus / a.tours
						  end	
            elseif condition == "minus" then
						  func = function(a,b) 
							return b.minus / b.tours < a.minus / a.tours
						  end	
					  elseif condition == "tours" then
					    func = function(a,b)
												if b.tour1 / b.tours < a.tour1 / a.tours then
												return true
												elseif b.tour1 / b.tours > a.tour1 / a.tours then
												return false
												elseif (b.tour1+b.tour2) / b.tours < ( a.tour1 + a.tour2) / a.tours then
												return true
												else
												return false
												end
						  end	
						elseif condition == "vp" then
						  func = function(a,b)
							return b.vp / b.tours < a.vp / a.tours 
							end
					  else
					    trace_out("bad condition" .. condition .. "\n")							
						end
						_G.table.sort(keys,func)
						%>
						<% for i,v in _G.ipairs(keys) do %>
						<tr>
							<td>第<%=i %>名</td>
							<td><%=v.name %></td>
							<% if condition == "tours" then %>
							<td><%=v.tour1 %></td>
							<td><%=v.tour2 %></td>
							<td><%=v.tour3 %></td>
							<%elseif condition == "vp" then %>
							<% local vp1 = v.vp / v.tours %>
							<% vp1 = _G.math.floor(vp1 * 100)/100 %>
							<td><%=vp1 %></td>
							<td><%=v.vp %></td>
							<% else %>
							<td><%=v.plus %></td>
							<td><%=v.minus %></td>
							<td><%=v.imps %></td>
							<% end %>
							<td><%=v.tours %></td>
						</tr>
						<% end %>
					</tbody>
				</table>
			</div>
			<% end %>
		</div>
	</body>
</html>	
