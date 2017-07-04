
namespace! :com, :example do
  namespace! :test do
    type! :Person do
      Mahuta.import(self, 'child')
    end
  end
end
