package handler

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"iqj/internal/database"
	"net/http"
	"strconv"
)

// Выдает массив с объявлениями, у которых срок годности
// больше текущей даты, если таких объявлений нет - вернет пустой массив
// GET /ad
func (h *Handler) HandleGetAdvertisement(c *gin.Context) {
	advertisementSlice, err := database.Database.Advertisement.Get()
	if err != nil {
		c.JSON(http.StatusInternalServerError, err.Error())
		fmt.Println("HandleGetAdvertisement:", err)
		return
	}

	c.JSON(http.StatusOK, advertisementSlice)
}

// Для пользователей с ролью moderator
// получает JSON в теле запроса вида:
//
//	{
//		"ad_content": " ",
//		"creation_date": " ",
//		"expiration_date": " "
//	}
//
// создает в бд переданное объявление.
// POST /api/ad
func (h *Handler) HandlePostAdvertisement(c *gin.Context) {
	userIdToConv, ok := c.Get("userId")
	if !ok {
		c.String(http.StatusUnauthorized, "User ID not found")
		fmt.Println("HandlePostAdvertisement:", ok)
		return
	}
	userId := userIdToConv.(int)

	user, err := database.Database.UserData.GetRoleById( // у этого юзера будет роль, все хорошо -> user.Role
		database.UserData{
			Id: int64(userId),
		})
	if err != nil {
		c.JSON(http.StatusInternalServerError, err.Error())
		fmt.Println("HandlePostAdvertisement:", err)
		return
	}

	if user.Role == "moderator" {
		var advertisement database.Advertisement

		err := c.BindJSON(&advertisement)
		if err != nil {
			c.String(http.StatusBadRequest, err.Error())
			fmt.Println("HandlePostAdvertisement:", err)
			return
		}

		ok := database.Database.Advertisement.Add(&advertisement)
		if ok != nil {
			c.JSON(http.StatusInternalServerError, ok.Error())
			fmt.Println("HandlePostAdvertisement:", ok)
			return
		}

		c.JSON(http.StatusOK, advertisement)
	} else {
		c.JSON(http.StatusForbidden, "There are not enough rights for this action")
	}
}

// Для пользователей с ролью moderator
// получает JSON в теле запроса вида:
//
//	{
//		"ad_id": " ",
//		"ad_content": " ",
//		"creation_date": " ",
//		"expiration_date": " "
//	}
//
// обновляет в бд объявление с переданным id.
// PUT /api/ad
func (h *Handler) HandleUpdateAdvertisements(c *gin.Context) {
	userIdToConv, ok := c.Get("userId")
	if !ok {
		c.String(http.StatusUnauthorized, "User ID not found")
		fmt.Println("HandleUpdateAdvertisement:", ok)
		return
	}
	userId := userIdToConv.(int)

	user, err := database.Database.UserData.GetRoleById( // у этого юзера будет роль, все хорошо -> user.Role
		database.UserData{
			Id: int64(userId),
		})
	if err != nil {
		c.JSON(http.StatusInternalServerError, err.Error())
		fmt.Println("HandleUpdateAdvertisement:", err)
		return
	}

	if user.Role == "moderator" {
		var advertisement database.Advertisement

		err := c.BindJSON(&advertisement)
		if err != nil {
			c.String(http.StatusBadRequest, err.Error())
			fmt.Println("HandleUpdateAdvertisement:", err)
			return
		}

		ok := database.Database.Advertisement.Update(&advertisement)
		if ok != nil {
			c.JSON(http.StatusInternalServerError, ok.Error())
			fmt.Println("HandleUpdateAdvertisement:", ok)
			return
		}

		c.JSON(http.StatusOK, advertisement)
	} else {
		c.JSON(http.StatusForbidden, "There are not enough rights for this action")
	}
}

// Функция для получения всех объявлений, имеющихся в бд на данный момент.
// Извлекает из запроса параметр all_ads, который должен быть равен 1 для работы.
// Используется функция GetAllAds, которая получает срез всех объявлений в бд.
// Использование с GET: /ad_all
func (h *Handler) HandleGetAllAdvertisements(c *gin.Context) {

	allads, err := database.Database.Advertisement.GetAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, err.Error())
		fmt.Println("HandleGetAllAdvertisements:", err)
		return
	}
	c.JSON(http.StatusOK, allads)
}

func (h *Handler) HandleDeleteAdvertisement(c *gin.Context) {
	userIdToConv, ok := c.Get("userId")
	if !ok {
		c.String(http.StatusUnauthorized, "User ID not found")
		fmt.Println("HandleDeleteAdvertisement:", ok)
		return
	}
	userId := userIdToConv.(int)

	user, err := database.Database.UserData.GetRoleById(
		database.UserData{
			Id: int64(userId),
		})
	if err != nil {
		c.JSON(http.StatusInternalServerError, err.Error())
		fmt.Println("HandleDeleteAdvertisement:", err)
		return
	}

	if user.Role == "moderator" {
		idStr := c.Query("id")
		id, err := strconv.Atoi(idStr)
		if err != nil {
			c.JSON(http.StatusBadRequest, err.Error())
			fmt.Println("HandleDeleteAdvertisement:", err)
			return
		}

		var advertisement database.Advertisement
		advertisement.Id = id

		_, err = database.Database.Advertisement.GetById(advertisement)
		if err != nil {
			c.JSON(http.StatusInternalServerError, "The advertisement with the specified id does not exist")
			fmt.Println("HandleDeleteAdvertisement:", err)
			return
		}

		err = database.Database.Advertisement.Delete(&advertisement)
		if err != nil {
			c.JSON(http.StatusInternalServerError, err.Error())
			fmt.Println("HandleDeleteAdvertisement:", err)
			return
		}

		c.JSON(http.StatusNoContent, fmt.Sprintf("The advertisement with the id=%v was successfully deleted", id))
	} else {
		c.JSON(http.StatusForbidden, "There are not enough rights for this action")
	}
}
