using PyCall
using Random
@pyimport PIL.Image as img
@pyimport matplotlib.pyplot as plt

# параметры
x, y, limit, onB = 180, 200, 120, 0
minA, maxA, pL = 190, 350, pi / 180
condition, losses = [[u, 1, 40.0] for u in 1:x], [n for n in 0.95:.01:1.05]
minE, maxE, count = 4.0, 4.5, 1
color= ["#00e0fe", "#00000000"]

# свободные заряды и массивы
for c1 = 1:x, c2 = 1:y
    if rand(0:100) > 90
        push!(condition, [c1, c2, rand(-20:20)])
    end
    c1 = 0
end
space = [[0.0 for _ in 0:x] for _ in 0:y]
lightnings = [[[rand(10:x-10)], [y], [rand(minE:.001:maxE)]] for _ in 1:count]
angle = []
branches = []
image = img.new(mode="RGB", size=(x, y))

# напряжение среды и картинка
for a in 1:y
    for b in 1:x
        t = 0
        for c in condition
            if (c[1] == b) && (c[2] == a)
                t += c[3]
            elseif (c[1] != b) || (c[2] != a)
                t += c[3] / ((c[1]-b)^2 + (c[2]-a)^2)
            end
        end
        space[a][b] = round(t; digits = 3)
        if space[a][b] >= 0
            image.putpixel((b-1, y-a), (0, round(Int, t*5), 0))
        else
            image.putpixel((b-1, y-a), (round(Int, abs(t*5)), 0, 0))
        end
    end
    println(a, "/", y)
end
println("Сompletion of the environment.")
# молнии
for e in 1:count
    print(lightnings[e], ": ")
    for l in 1:limit
        new = [round(Int, lightnings[e][1][l] - rand(-1:1)),
            round(Int, lightnings[e][2][l] - 1)]
        if new[1] < 0
            continue
        end
        for g in minA:maxA
            temp = [round(Int, lightnings[e][1][l] + lightnings[e][3][l] * cos(g * pL)),
                round(Int, lightnings[e][2][l] + lightnings[e][3][l] * sin(g * pL))]
            if (temp[1] == new[1]) && (temp[2] == new[2])
                continue
            elseif (0 < temp[1] <= x) && (0 < temp[2] <= y) && (temp[2] < lightnings[e][2][l])
                if  temp[2] <= 1
                    new = [temp[1], temp[2]]
                    break
                end
                t1 = round(Int, lightnings[e][1][l] + (lightnings[e][3][l] * cos(g * pL))/2)
                t2 = round(Int, lightnings[e][2][l] + (lightnings[e][3][l] * sin(g * pL))/2)
                charge = [space[new[2]][new[1]], space[temp[2]][temp[1]]]
                if space[t2][t1] < charge[2]
                    continue
                elseif ((charge[2] >= charge[1]) && (temp[2] < new[2])) || ((charge[2] > charge[1]) && (charge[2] > 0))
                    new, charge[1] = [temp[1], temp[2]], charge[2]
                end
            end
        end
        print(space[new[2]][new[1]], " in ", new,  "; ")
        push!(lightnings[e][1], new[1])
        push!(lightnings[e][2], new[2])
        push!(lightnings[e][3], round(lightnings[e][3][l] * losses[rand(1:11)], digits=3))
        if last(lightnings[e][2]) <= 1
            break
        end
    end
    println("")
end
println("Completion of lightning.")
# отображение
fig, ax = plt.subplots()
ax.set_xlim(0.5, x+0.5)
ax.set_ylim(0.5, y+0.5)
plt.imshow(image, extent=([0.5, x+0.5, 0.5, y+0.5]))
for l in lightnings
    plt.plot(l[1], l[2], color=color[1], linewidth=1.2 , marker="o", markersize=1, markerfacecolor=color[1], zorder=3)
end
plt.show()
