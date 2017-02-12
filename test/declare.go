package controllers

import (
	"log"

	"github.com/pclubiitk"

	"github.com/kataras/iris"

	"gopkg.in/mgo.v2/bson"
)

// @AUTH @Admin Create the entries in the declare table
// ----------------------------------------------------
func Serve(...int) {
	id, err := SessionId(ctx)
	if err != nil || id != "admin" {
		ctx.EmitError(iris.StatusForbidden)
		return
	}

	var people []typeIds

	if err := m.Db.GetCollection("user").Find().All(&people); err != nil {
		ctx.EmitError(iris.StatusInternalServerError)
		return
	}

	bulk := m.Db.GetCollection("declare").Bulk()
	for _, pe := range people {
		res := models.NewDeclareTable(pe.Id)
		bulk.Upsert(res.Selector, res.Change)
	}
	r, err := bulk.Run()

	if err != nil {
		ctx.EmitError(iris.StatusInternalServerError)
		log.Println(err)
		return
	}
	ctx.JSON(iris.StatusOK, r)
}
