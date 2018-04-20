require 'spec_helper'
require 'spaceborne'
require 'curlyrest'

include Spaceborne

def create_target_todo
  post 'http://localhost:3000/todos', {title: 'A screamer', created_by: 'kw'}
end

def delete_todos(filter)
  get 'http://localhost:3000/todos'
  res = json_body
  res.each do |r|
    unless filter.match(r[:title])
      delete "http://localhost:3000/todos/#{r[:id]}"
      expect_status(204)
    end
  end
end

describe 'API testing of RESTful todos local app' do
  after(:all) do
    delete_todos(/.*do_not_delete.*/)
  end
  it "head" do
    wrap_request do
      head 'http://localhost:3000/todos'
      expect_status(200)
      expect_header_types(content_type: :string, etag: :string, 
        cache_control: :string, x_request_id: :string,
        x_runtime: :string)
      expect(response.body).to eq('')
    end
  end
  it "list" do
    wrap_request do
      get 'http://localhost:3000/todos'
      expect_status(200)
      expect_json_types('*', id: :integer, title: :string, created_by: :string,
        created_at: :date, updated_at: :date)
    end
  end
  it "get of particular todo" do
    wrap_request do
      get 'http://localhost:3000/todos/3'
      expect_status(200)
      expect_json(title: 'do_not_delete')
      expect_json_types(id: :integer, title: :string, created_by: :string,
        created_at: :date, updated_at: :date)
    end
  end
  it "get of non-existant todo" do
    wrap_request do
      get 'http://localhost:3000/todos/999999999'
      expect_status(404)
      expect_json(message: "Couldn't find Todo with 'id'=999999999")
    end
  end
  it "post w json" do
    wrap_request do
      post 'http://localhost:3000/todos', {title: 'A screamer', created_by: 'kw'}
      expect_status(201)
      expect_json(title: 'A screamer', created_by: 'kw')
      expect_json_types(id: :integer, created_at: :date, updated_at: :date)
    end
  end
  it "post w form data" do
    wrap_request do
      post 'http://localhost:3000/todos', {title: 'A screamer', created_by: 'kw'},
        {nonjson_data: true}
      expect_status(201)
      expect_json(title: 'A screamer', created_by: 'kw')
      expect_json_types(id: :integer, created_at: :date, updated_at: :date)
    end
  end
  it "post w query data" do
    wrap_request do
      post 'http://localhost:3000/todos', {}, {'params' => {'title' => 'A screamer', 
        'created_by' => 'kw'}}
      expect_status(201)
      expect_json(title: 'A screamer', created_by: 'kw')
      expect_json_types(id: :integer, created_at: :date, updated_at: :date)
    end
  end
  it "put" do
    wrap_request do
      put "http://localhost:3000/todos/3", {title: 'do_not_delete', created_by: 'kw'}
      expect_status(204)
    end
  end
  it "put non-existant" do
    wrap_request do
      put "http://localhost:3000/todos/999999999", {title: 'do_not_delete', created_by: 'kw'}
      expect_status(404)
    end
  end 
  it "put bad data" do
    wrap_request do
      put "http://localhost:3000/todos/3", {bad_data: 'oops'}
      expect_status(204)
    end
  end 
  it "delete - no data" do
    wrap_request do
      create_target_todo
      @todo = json_body
      delete "http://localhost:3000/todos/#{@todo[:id]}"
      expect_status(204)
    end
  end
  it "delete - data ignored" do
    wrap_request do
      create_target_todo
      @todo = json_body
      delete "http://localhost:3000/todos/#{@todo[:id]}", {foo: 'bar'}
      expect_status(204)
    end
  end
  it "delete non-existant" do
    wrap_request do
      delete "http://localhost:3000/todos/999999999", {title: 'do_not_delete', created_by: 'kw'}
      expect_status(404)
    end
  end 
end